それぞれ詳しく解説します。

---

### 1. 「どの構成図番号か」を自動判別するタグ設計・マッピングロジック

【タグ設計例】
- EC2や他リソースに「DiagramNumber」や「SystemPart」などのカスタムタグを付与
- 例:
  - DiagramNumber = "1"
  - SystemPart = "WebServer"

【Terraform例】
```hcl
resource "aws_instance" "web" {
  # ...省略...
  tags = {
    Name          = "portfolio-web"
    DiagramNumber = "1"
    SystemPart    = "WebServer"
  }
}
```

【Lambda側のマッピングロジック例（Python）】
- CloudWatchアラートの「Trigger」や「Dimensions」からInstanceIdを取得
- boto3でEC2のタグ情報を取得し、DiagramNumberを参照
```python
import boto3

def get_diagram_number(instance_id):
    ec2 = boto3.client('ec2')
    res = ec2.describe_instances(InstanceIds=[instance_id])
    tags = res['Reservations'][0]['Instances'][0]['Tags']
    for tag in tags:
        if tag['Key'] == 'DiagramNumber':
            return tag['Value']
    return "不明"
```
- これをメッセージ整形時に組み込む

---

### 2. アラート抑止（サプレッション）や集約の仕組み

【基本方針】
- Lambdaで「同じアラートが短時間に何度も来た場合は抑止」する
- DynamoDBなどに「直近のアラート送信時刻」を記録し、一定時間内は通知しない
- 集約：複数アラートをまとめて1件の通知にする（バッチ処理や定期実行Lambdaで集約）

【Lambda抑止ロジック例（Python）】
```python
import boto3
import time

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('AlertSuppression')

def should_notify(alarm_name):
    now = int(time.time())
    item = table.get_item(Key={'AlarmName': alarm_name}).get('Item')
    if item and now - item['LastNotified'] < 600:  # 10分以内なら抑止
        return False
    table.put_item(Item={'AlarmName': alarm_name, 'LastNotified': now})
    return True
```
- Lambdaの先頭でこの関数を呼び、Falseならreturnして通知しない

---

### 3. テスト用のCloudWatchアラート発火方法（CPU負荷を意図的に上げる等）

【EC2でCPU負荷を上げるコマンド例（Linux）】
```sh
sudo yum install -y stress
stress --cpu 2 --timeout 300
```
- これで2コア分のCPUを5分間100%にします

【Windowsの場合】
- PowerShellで無限ループ
```powershell
while ($true) {}
```

【CloudWatchアラートの閾値を一時的に下げてテストする方法も有効です】

---

ご希望があれば、これらのTerraformリソース例やLambdaサンプルもさらに詳しくご案内できます。
どこを深掘りしたいか教えてください！
