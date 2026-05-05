echo "<h1>AppServer is running</h1>" > /usr/share/nginx/html/index.html
#!/bin/bash
yum update -y
yum install -y python3 python3-pip -y
pip3 install flask mysql-connector-python

# Flaskアプリ配置
cat << 'EOF' > /opt/app.py
from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

def get_db_connection():
	return mysql.connector.connect(
		host="${rds_endpoint}",
		user="${rds_user}",
		password="${rds_pass}",
		database="${rds_db}"
	)

@app.route("/")
def index():
	return "Flask Web Server is running!"

@app.route("/query", methods=["GET"])
def query():
	sql = request.args.get("sql", "SHOW DATABASES;")
	try:
		conn = get_db_connection()
		cursor = conn.cursor()
		cursor.execute(sql)
		result = cursor.fetchall()
		cursor.close()
		conn.close()
		return jsonify(result)
	except Exception as e:
		return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
	app.run(host="0.0.0.0", port=80)
EOF

# Flaskアプリ起動（systemdで自動起動も可。ここでは簡易にバックグラウンド起動）
nohup python3 /opt/app.py &
