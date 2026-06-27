# 08 CloudWatch Alert Construct

CloudWatch アラートの設計・構築と、SNS → Lambda によるアラートメッセージ整形の実装例。
通知内容をそのまま流すのではなく、Lambda で整形してから通知先へ送る構成を Terraform で実現している。

---

## アラート通知フロー

```
┌──────────────────────────────────────────────────────┐
│                   CloudWatch                         │
│                                                      │
│  メトリクス監視                                      │
│  CPU 使用率 / エラー率 / レイテンシ 等               │
│               │                                      │
│          閾値超過                                    │
│               │                                      │
└───────────────┼──────────────────────────────────────┘
                ▼
        ┌──────────────┐
        │  SNS Topic   │
        └──────┬───────┘
               │ サブスクリプション
               ▼
        ┌──────────────┐
        │  Lambda      │
        │  (整形処理)   │
        │              │
        │  [構成図: 1]  │
        │  AlarmName   │
        │  StateReason │
        └──────┬───────┘
               │
               ▼
        Slack / メール / その他通知先
```

---

## 実装内容

### CloudWatch + SNS（sns_rule.tf）
- EC2 インスタンスへの CloudWatch メトリクス監視設定
- 閾値超過時に SNS トピックへ通知

### Lambda アラート整形（alert-formatter.py）
```python
def lambda_handler(event, context):
    message = json.loads(event['Records'][0]['Sns']['Message'])
    # アラーム名・原因を整形してカスタムフォーマットで出力
    formatted_message = f"[構成図: 1] {message.get('AlarmName')} - {message.get('NewStateReason')}"
    # ここで Slack 等の通知先へ送信する処理を追加
```

SNS の生メッセージをそのまま通知するのではなく、Lambda でフォーマットを制御することで、通知先のメッセージを一元管理できる。

---

## ファイル構成

```
08-alratConstruct/
├── EC2.tf                         # 監視対象 EC2 定義
├── sns_rule.tf                    # SNS トピック + CloudWatch アラーム
├── alert-formatter.py             # Lambda（メッセージ整形）
├── alert_formatter.zip            # Lambda デプロイパッケージ
├── data_aws.tf                    # AMI データソース
├── providers.tf
├── 01_cloudwatch_alert_design_lab.md  # アラート設計ガイド
├── advanced_measure.md            # 応用設計メモ
└── 学習内容まとめ.md              # 学習成果
```

---

## 実行方法

```bash
terraform init
terraform apply

# アラームのテスト（State を強制変更）
aws cloudwatch set-alarm-state \
  --alarm-name <ALARM_NAME> \
  --state-value ALARM \
  --state-reason "テスト通知"
```

---

## 設計のポイント

| 観点 | 実装内容 |
|------|---------|
| メッセージ管理 | Lambda でフォーマットを集約・制御 |
| 拡張性 | 通知先は Lambda 内で切り替え可能 |
| 監視設定 | Terraform で CloudWatch アラームをコード管理 |
