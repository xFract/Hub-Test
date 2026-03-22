import os
import subprocess
import sys
from argparse import ArgumentParser
from datetime import datetime
from pathlib import Path
from typing import Sequence, Union

REPO_ROOT = Path(__file__).resolve().parent
Command = Union[str, Sequence[str]]


def resolve_python_command() -> list[str]:
    return [sys.executable, str(REPO_ROOT / "build.py")]


def run_command(command: Command, description: str) -> bool:
    printable = command if isinstance(command, str) else subprocess.list2cmdline(list(command))
    print(f"\n[INFO] {description}: {printable}")
    try:
        result = subprocess.run(command, check=True, text=True, capture_output=True, cwd=REPO_ROOT)
        if result.stdout:
            print(result.stdout.strip())
        if result.stderr:
            print(result.stderr.strip())
        print(f"[OK] {description}")
        return True
    except FileNotFoundError as exc:
        print(f"[ERROR] {description}: command not found: {exc.filename}")
        return False
    except subprocess.CalledProcessError as exc:
        print(f"[ERROR] {description}: failed with exit code {exc.returncode}")
        if exc.stdout:
            print("--- STDOUT ---")
            print(exc.stdout.strip())
        if exc.stderr:
            print("--- STDERR ---")
            print(exc.stderr.strip())
        return False


def run_git_command(args: Sequence[str], check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        check=check,
        text=True,
        capture_output=True,
        cwd=REPO_ROOT,
    )


def has_git_changes() -> bool:
    return bool(run_git_command(["status", "--porcelain"]).stdout.strip())


def get_git_status() -> str:
    return run_git_command(["status", "--short"]).stdout.strip()


def get_current_branch() -> str:
    return run_git_command(["rev-parse", "--abbrev-ref", "HEAD"], check=True).stdout.strip()


def get_upstream_branch() -> str:
    result = run_git_command(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"])
    if result.returncode != 0:
        return ""
    return result.stdout.strip()


def ask_for_confirmation(prompt: str, auto_confirm: bool) -> bool:
    if auto_confirm:
        print(f"[INFO] Auto-confirmed: {prompt}")
        return True

    try:
        answer = input(f"{prompt} [y/N]: ").strip().lower()
    except EOFError:
        return False

    return answer in {"y", "yes"}


def parse_args():
    parser = ArgumentParser(description="Build, review, commit, and push this repository safely.")
    parser.add_argument("--yes", action="store_true", help="skip confirmation prompts")
    parser.add_argument("--message", help="explicit commit message")
    parser.add_argument("--skip-build", action="store_true", help="skip running build.py")
    return parser.parse_args()


def main():
    args = parse_args()

    print("====================================")
    print("[INFO] Auto Build and Push Script")
    print("====================================")

    os.chdir(REPO_ROOT)

    if not args.skip_build:
        print("\n[STEP 1] Build project")
        if not run_command(resolve_python_command(), "Build project"):
            print("\n[FAILED] Build failed. Aborting.")
            sys.exit(1)
    else:
        print("\n[STEP 1] Skipping build")

    print("\n[STEP 2] Inspect git changes")
    if not has_git_changes():
        print("\n[WARN] No changes detected. Nothing to commit.")
        sys.exit(0)

    branch = get_current_branch()
    upstream = get_upstream_branch()
    status_output = get_git_status()

    print(f"\n[INFO] Current branch: {branch}")
    print(f"[INFO] Upstream: {upstream or '(none)'}")
    print("\n[INFO] Pending changes:")
    print(status_output)

    if not ask_for_confirmation("Stage, commit, and push these changes?", args.yes):
        print("\n[STOPPED] Cancelled before staging.")
        sys.exit(0)

    print("\n[STEP 3] Stage changes")
    if not run_command(["git", "add", "-A"], "Stage changes"):
        sys.exit(1)

    commit_message = args.message or f"Auto-update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    print(f"\n[STEP 4] Commit changes ({commit_message})")
    if not run_command(["git", "commit", "-m", commit_message], "Commit changes"):
        sys.exit(1)

    if upstream:
        print("\n[STEP 5] Rebase onto upstream")
        if not run_command(["git", "pull", "--rebase"], "Rebase onto upstream"):
            print("\n[FAILED] Rebase failed. Resolve conflicts before pushing.")
            sys.exit(1)
    else:
        print("\n[STEP 5] No upstream configured. Skipping rebase.")

    push_command = ["git", "push", "origin", branch]
    if not upstream:
        push_command = ["git", "push", "-u", "origin", branch]

    print("\n[STEP 6] Push changes")
    if not run_command(push_command, "Push changes"):
        print("\n[FAILED] Push failed.")
        sys.exit(1)

    print("\n[SUCCESS] Build, commit, and push completed successfully.")


if __name__ == "__main__":
    main()
