# AWSログ取得先一覧表

| ログ種別 | CloudWatchで取得 | S3で取得 | 備考 |
|---|:---:|:---:|---|
| CloudTrail（API操作履歴） | △ | ○ | CloudWatch Events経由で一部可、標準はS3 |
| CloudWatch Logs（アプリ・システム・カスタムログ） | ○ | △ | CloudWatch Logsが主、エクスポートでS3も可 |
| S3アクセスログ | × | ○ | S3バケットに直接出力 |
| VPC Flow Logs | ○ | ○ | どちらにも出力可能（選択式） |
| ELBアクセスログ | × | ○ | S3バケットに直接出力 |
| RDS/Auroraログ | ○ | ○ | CloudWatch LogsまたはS3にエクスポート可 |
| Lambdaログ | ○ | △ | CloudWatch Logsが主、S3はDLQやエクスポート経由 |
| API Gatewayアクセスログ・実行ログ | ○ | △ | CloudWatch Logsが主、S3はエクスポート等で可 |
| VPCエンドポイント（Interface/ Gateway Endpoint）アクセスログ | ○ | ○ | どちらにも出力可能（選択式） |
| lambdaのデッドレターキュー | × | ○ | SQS/SNS/S3が選択可（S3はDLQとして） |
| route53ログ | × | ○ | S3バケットに直接出力（クエリログ） |
| WAFの確認 | ○ | ○ | CloudWatch LogsまたはS3に出力可 |
| GuardDutyのログの確認 | × | ○ | S3バケットにエクスポート可 |
| ロードバランサーのログの確認 | × | ○ | S3バケットに直接出力（ALB/NLB/CLB） |
| EC2のcloudwatch Agentのログ | ○ | △ | CloudWatch Logsが主、S3はエクスポート等で可 |
| その他各サービス固有のログ | △ | △ | サービスごとに異なる |

---

凡例：○＝取得可、△＝一部可/設定次第、×＝不可
