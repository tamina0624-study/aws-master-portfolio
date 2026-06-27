# 08 CloudWatch Alert Construct

---

> 「深夜にサーバーの CPU が 100% になって応答が止まっていたのに、
> 朝になって問い合わせが来るまで誰も気づかなかった。」

> 「アラートは来ているんだけど、内容が AWS の生メッセージそのままで読みにくい。
> 大量に来すぎて、どれが本当に重要なのか分からなくなってきた。」

システムの異常を「人が気づく前に検知して通知する」仕組みが **CloudWatch アラート** です。
CPU・メモリ・エラー率などのメトリクスを常時監視し、閾値を超えた瞬間に **SNS** 経由で通知できます。
さらに **Lambda** を挟むことで、通知内容のフォーマットを自由にカスタマイズできます。
「どの構成図のどのリソースで何が起きたか」を整形して Slack に流すなど、運用チームが即座に行動できる通知設計が可能です。

本プロジェクトは、その CloudWatch + SNS + Lambda によるアラート設計と通知整形の仕組みを Terraform で実装した学習成果です。

## 解説動画

[![YouTube](https://img.shields.io/badge/YouTube-解説動画-FF0000?logo=youtube&logoColor=white)](https://youtu.be/Y2yxavm9STY?si=weQZlMQs64X0eRdQ)

---

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
