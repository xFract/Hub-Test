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
    # 1. PATH から直接検索
    direct = shutil.which(name)
    if direct:
        return direct

    # 2. カスタムパス候補
    search_dirs = [
        AFTMAN_BIN,
        Path.home() / ".aftman" / "bin",
        Path(r"D:\APP\aftman-0.3.0-windows-x86_64"),
    ]

    for directory in search_dirs:
        if os.name == "nt":
            local_exe = directory / f"{name}.exe"
            if local_exe.exists():
                return str(local_exe)
        
        local_cmd = directory / name
        if local_cmd.exists():
            return str(local_cmd)

    return None


def ensure_command(name: str) -> str:
    resolved = resolve_command(name)
    if resolved:
        return resolved

    # aftman 自体が見つからない場合のメッセージを親切にする
    if name == "aftman":
        raise RuntimeError(
            "aftman が見つかりません。https://github.com/LPGhatguy/aftman からインストールしてください。"
        )

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

    # 外部ツール (darklua等) が PATH から見つかるよう ~/.aftman/bin を追加
    aftman_bin_str = str(Path.home() / ".aftman" / "bin")
    if aftman_bin_str not in os.environ["PATH"]:
        os.environ["PATH"] = aftman_bin_str + os.pathsep + os.environ["PATH"]

    DIST_DIR.mkdir(exist_ok=True)

    required_tools = ["rojo", "lune", "darklua"]
    missing_tools = [t for t in required_tools if resolve_command(t) is None]

    if missing_tools:
        print(f"[WARN] 以下のツールが見つかりません: {', '.join(missing_tools)}")
        aftman = resolve_command("aftman")
        if aftman:
            print("[INFO] aftman install を実行してツールの復旧を試みます...")
            try:
                # 初期環境での信頼確認エラーを避けるため --no-trust-check を付与
                subprocess.run([aftman, "install", "--no-trust-check"], check=True, cwd=REPO_ROOT)
                print("[OK] ツールのインストールが完了しました。")
            except subprocess.CalledProcessError:
                print("[ERROR] aftman install に失敗しました。手動で実行してください。")
                sys.exit(1)
        else:
            print("[ERROR] aftman 自体が見つからないため、自動インストールができません。")
            print("https://github.com/LPGhatguy/aftman から aftman をインストールしてください。")
            sys.exit(1)

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
