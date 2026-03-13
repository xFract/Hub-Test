import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Optional, Sequence, Union

REPO_ROOT = Path(__file__).resolve().parent
DIST_DIR = REPO_ROOT / "dist"
AFTMAN_BIN = REPO_ROOT / ".aftman" / "bin"
Command = Union[str, Sequence[str]]


def resolve_command(name: str) -> Optional[str]:
    direct = shutil.which(name)
    if direct:
        return direct

    if os.name == "nt":
        local_exe = AFTMAN_BIN / f"{name}.exe"
        if local_exe.exists():
            return str(local_exe)

    local_cmd = AFTMAN_BIN / name
    if local_cmd.exists():
        return str(local_cmd)

    return None


def ensure_command(name: str) -> str:
    resolved = resolve_command(name)
    if resolved:
        return resolved

    raise RuntimeError(
        f"'{name}' が見つかりません。PATH に追加するか、`aftman install` を実行して .aftman/bin を用意してください。"
    )


def run_command(command: Command, description: str) -> None:
    printable = command if isinstance(command, str) else subprocess.list2cmdline(list(command))
    print(f"\n[{description}] 実行中: {printable}")
    try:
        result = subprocess.run(command, check=True, text=True, capture_output=True, cwd=REPO_ROOT)
        if result.stdout:
            print(result.stdout.strip())
        print(f"[OK] {description} に成功しました！")
    except FileNotFoundError as e:
        print(f"[ERROR] {description} に失敗しました。実行ファイルが見つかりません: {e.filename}")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {description} に失敗しました。 (Exit Code: {e.returncode})")
        if e.stdout:
            print("--- STDOUT ---")
            print(e.stdout.strip())
        if e.stderr:
            print("--- STDERR ---")
            print(e.stderr.strip())
        sys.exit(1)


def main():
    print("[INFO] Fract-Hub のビルドを開始します...")
    os.chdir(REPO_ROOT)

    DIST_DIR.mkdir(exist_ok=True)

    try:
        rojo = ensure_command("rojo")
        lune = ensure_command("lune")
    except RuntimeError as e:
        print(f"[ERROR] ビルドを開始できません: {e}")
        sys.exit(1)

    run_command([rojo, "build", "-o", str(DIST_DIR / "main.rbxm")], "Rojoによるビルド")
    run_command([lune, "build"], "LuneによるLuaファイルのバンドル")

    print("\n[SUCCESS] 全てのビルドプロセスが正常に完了しました！ `dist/main.lua` が更新されています。")


if __name__ == "__main__":
    main()
