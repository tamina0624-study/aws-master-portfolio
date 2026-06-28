import json
import importlib
import os


def lambda_handler(event, context):
    """Connect to RDS and fetch a single row."""
    pymysql = importlib.import_module("pymysql")

    conn = pymysql.connect(
        host=os.environ["DB_HOST"],
        port=int(os.environ.get("DB_PORT", "3306")),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ.get("DB_NAME") or None,
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor,
    )

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1 AS value")
            row = cursor.fetchone()
    finally:
        conn.close()

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"data": row}),
    }
