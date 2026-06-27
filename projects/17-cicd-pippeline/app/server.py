from flask import Flask, Response, jsonify

app = Flask(__name__)


@app.route("/")
def index() -> Response:
    return jsonify({"message": "hello", "status": "ok"})


@app.route("/health")
def health() -> Response:
    return jsonify({"status": "healthy"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8082)
