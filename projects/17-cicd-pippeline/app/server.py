import subprocess

from flask import Flask, Response, jsonify, request

app = Flask(__name__)


@app.route("/")
def index() -> Response:
    return jsonify({"message": "hello", "status": "ok"})


@app.route("/health")
def health() -> Response:
    return jsonify({"status": "healthy"})


# TODO: CodeQL テスト用 - コマンドインジェクション脆弱性（要削除）
# CWE-78: ユーザー入力を検証せず subprocess に渡している
@app.route("/debug")
def debug() -> Response:
    cmd = request.args.get("cmd", "echo hello")
    result = subprocess.check_output(cmd, shell=True)
    return jsonify({"output": result.decode()})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8083)
