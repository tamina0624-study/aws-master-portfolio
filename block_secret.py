
import subprocess
import sys
import re
import yaml

def load_keywords_section(filepath, section):
    try:
        with open(filepath, encoding="utf-8") as f:
            data = yaml.safe_load(f)
        return data.get(section, [])
    except Exception as e:
        print(f"[INFO] キーワードファイルが取得できませんでした: {e}")
        return []

keywords = load_keywords_section("projects/00-Secret/keywords.txt", "secret")
patterns = [re.compile(re.escape(word), re.IGNORECASE) for word in keywords]

result = subprocess.run(
    ["git", "diff", "--cached", "--name-only"],
    stdout=subprocess.PIPE,
    encoding="utf-8"
)
found = False
for line in result.stdout.splitlines():
    for pattern in patterns:
        if pattern.search(line):
            try:
                with open("projects/00-Secret/secret_detected.log", "a", encoding="utf-8") as f:
                    f.write(f"Secret keyword detected: {line}\n")
            except Exception as e:
                print(f"[INFO] ログファイルに書き込めませんでした: {e}")
            found = True
            break
if found:
    sys.exit(1)
