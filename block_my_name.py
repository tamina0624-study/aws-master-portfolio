
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

keywords = load_keywords_section("projects/00-Secret/keywords.txt", "name")
patterns = [re.compile(re.escape(word), re.IGNORECASE) for word in keywords]

result = subprocess.run([
    "git", "diff", "--cached", "-U0"
], stdout=subprocess.PIPE, encoding="utf-8")
found = False
current_file = None
current_line = None
already_reported = set()
try:
    with open("projects/00-Secret/secret_detected.log", "a", encoding="utf-8") as f:
        for line in result.stdout.splitlines():
            if line.startswith('+++ b/'):
                current_file = line[6:]
            elif line.startswith('@@'):
                m = re.search(r'\+(\d+)', line)
                current_line = int(m.group(1)) if m else None
            elif line.startswith('+') and not line.startswith('+++'):
                content = line[1:]
                key = (current_file, current_line, content.strip())
                for pattern in patterns:
                    if pattern.search(content) and key not in already_reported:
                        f.write(f"ERROR: Name detected in {current_file} at line {current_line}: {content.strip()}\n")
                        found = True
                        already_reported.add(key)
                        break
except Exception as e:
    print(f"[INFO] ログファイルに書き込めませんでした: {e}")
if found:
    sys.exit(1)
