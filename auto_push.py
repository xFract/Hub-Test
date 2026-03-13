import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Sequence, Union

REPO_ROOT = Path(__file__).resolve().parent
Command = Union[str, Sequence[str]]


def resolve_python_command():
    """ビルド用のPythonコマンドとスクリプトパスを返す"""
    return [sys.executable, str(REPO_ROOT / "build.py")]


def run_command(command: Command, description: str) -> bool:
    printable = command if isinstance(command, str) else subprocess.list2cmdline(list(command))
    print(f"\n[INFO] {description} 実行中: {printable}")
    try:
        result = subprocess.run(command, check=True, text=True, capture_output=True)
        if result.stdout:
            print(result.stdout.strip())
        print(f"[OK] {description} に成功しました！")
        return True
    except FileNotFoundError as e:
        print(f"[ERROR] {description} に失敗しました。実行ファイルが見つかりません: {e.filename}")
        return False
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {description} に失敗しました。 (Exit Code: {e.returncode})")
        if e.stdout:
            print("--- STDOUT ---")
            print(e.stdout.strip())
        if e.stderr:
            print("--- STDERR ---")
            print(e.stderr.strip())
        return False


def has_git_changes() -> bool:
    result = subprocess.run(
        ["git", "status", "--porcelain"],
        check=False,
        text=True,
        capture_output=True,
        cwd=REPO_ROOT,
    )
    return bool(result.stdout.strip())


def main():
    print("====================================")
    print("[INFO] Auto Build & Push Script")
    print("====================================")

    os.chdir(REPO_ROOT)

    print("\n[STEP 1] プロジェクトのビルド")
    if not run_command(resolve_python_command(), "ビルドプロセスの実行"):
        print("\n[FAILED] ビルドに失敗したため、プッシュを中止します。")
        sys.exit(1)

    print("\n[STEP 2] 変更の確認")
    if not has_git_changes():
        print("\n[WARN] 変更されたファイルがありません。何もコミット/プッシュされません。")
        sys.exit(0)

    print("\n[STEP 3] 変更をステージング (git add .)")
    if not run_command(["git", "add", "."], "ステージング"):
        sys.exit(1)

    now = datetime.now()
    commit_msg = f"Auto-update: {now.strftime('%Y-%m-%d %H:%M:%S')}"

    print(f"\n[STEP 4] コミット (メッセージ: '{commit_msg}')")
    if not run_command(["git", "commit", "-m", commit_msg], "コミット"):
        sys.exit(1)

    print("\n[STEP 5] リモートから最新の変更を取得 (git pull --rebase origin master)")
    if not run_command(["git", "pull", "--rebase", "origin", "master"], "プル"):
        print("\n[FAILED] プルに失敗しました。ローカルとリモートの間にコンフリクトがある可能性があります。")
        sys.exit(1)

    print("\n[STEP 6] リモートへのプッシュ (git push origin master)")
    if not run_command(["git", "push", "origin", "master"], "プッシュ"):
        print("\n[FAILED] プッシュに失敗しました。")
        sys.exit(1)

    print("\n[SUCCESS] 全てのプロセス（ビルド -> コミット -> プッシュ）が完了しました！")


if __name__ == "__main__":
    main()
