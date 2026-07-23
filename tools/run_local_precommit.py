import subprocess
import os
import sys

CONFIG_FILE = ".pre-commit-config.local.yaml"

def main():

    print("came", flush=True)
    sys.exit(1)

    if not os.path.exists(CONFIG_FILE):
        sys.exit(0)

    if os.environ.get("SKIP_LOCAL_PRECOMMIT") == "1":
        sys.exit(0)

    env = os.environ.copy()
    env["SKIP_LOCAL_PRECOMMIT"] = "1"

    # ★ stagedファイル取得
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True,
        text=True
    )

    files = [f for f in result.stdout.splitlines() if f]

    if not files:
        sys.exit(0)

    cmd = ["py", "-m", "pre_commit", "run", "--config", CONFIG_FILE, "--files"] + files

    result = subprocess.run(cmd, env=env)

    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
