
import subprocess
import sys
import yaml


def load_keywords_section(filepath, section):
    try:
        with open(filepath, encoding="utf-8") as f:
            data = yaml.safe_load(f)
        return data.get(section, [])
    except Exception as e:
        print(f"[INFO] キーワードファイルが取得できませんでした: {e}")
        return []

keywords = load_keywords_section("projects/00-Secret/keywords.txt", "env")

result = subprocess.run(
    ["git", "diff", "--cached", "--name-only"],
    stdout=subprocess.PIPE,
    encoding="utf-8"
)
found = False
try:
    with open("projects/00-Secret/secret_detected.log", "a", encoding="utf-8") as f:
        for line in result.stdout.splitlines():
            for keyword in keywords:
                if line.strip().endswith(keyword):
                    f.write(f"ERROR: .env file detected! Commit blocked. ({line.strip()})\n")
                    found = True
                    break
except Exception as e:
    print(f"[INFO] ログファイルに書き込めませんでした: {e}")
if found:
    sys.exit(1)
