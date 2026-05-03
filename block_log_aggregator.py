
import sys
import os

def main():
    log_file = "projects/00-Secret/secret_detected.log"
    seen = set()
    found = False
    if os.path.exists(log_file):
        try:
            with open(log_file, encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and line not in seen:
                        print(line)
                        found = True
                        seen.add(line)
            # ログファイルは毎回消す（次回の重複防止）
            os.remove(log_file)
        except Exception as e:
            print(f"[INFO] シークレットログファイルが読み込めませんでした: {e}")
            # 読めなければ何もせずスキップ
    if found:
        sys.exit(1)

if __name__ == "__main__":
    main()
