import json

def lambda_handler(event, context):
    # SNSメッセージを取得
    message = json.loads(event['Records'][0]['Sns']['Message'])
    # 例：構成図番号やリソース名を付加してメッセージ整形
    formatted_message = f"[構成図: 1] {message.get('AlarmName')} - {message.get('NewStateReason')}"
    # ここでSlackや他の通知先に送信する処理を追加
    print(formatted_message)
    return {"status": "ok"}
