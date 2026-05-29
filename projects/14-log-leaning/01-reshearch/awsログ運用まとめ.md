# AWSにおけるログ運用の観点まとめ

## 1. ログの種類
- CloudTrail（API操作履歴）
- CloudWatch Logs（アプリ・システム・カスタムログ）
- S3アクセスログ
- VPC Flow Logs（ネットワークトラフィック）
- ELBアクセスログ
- RDS/Auroraログ
- Lambdaログ
- API Gatewayアクセスログ・実行ログ
- VPCエンドポイント（Interface/ Gateway Endpoint）アクセスログ
- lambdaのデッドレターキュー
- route53ログ
- WAFの確認
- GuardDutyのログの確認
- ロードバランサーのログの確認
- EC2のcloudwatch Agentのログ
- その他各サービス固有のログ

## 2. ログフォーマット
- JSON形式（CloudTrail、CloudWatch Logsなど）
- テキスト/CSV形式（S3アクセスログ、ELBログなど）
- サービスごとに出力形式が異なるため、公式ドキュメントで要確認

## 3. 可視化の手段
- CloudWatch Logs Insights（クエリによる分析・可視化）
- CloudWatchダッシュボード
- Amazon Athena（S3上のログをSQLで分析）
- Amazon QuickSight（BIツールでの可視化）
- 外部SIEM連携（Splunk, Datadog等）
- 各種メトリクスの確認
- glafaの確認

## 4. トラブル調査の手順
1. 関連するサービスのログを特定
2. CloudWatch Logs InsightsやAthenaで検索・抽出
3. 必要に応じてフィルタやクエリで絞り込み
4. イベントの時系列やエラー内容を確認
5. 原因特定・対策検討

## 5. その他重要な観点
- ログの保存期間・ライフサイクル管理（S3バケットのライフサイクル設定等）
- ログのセキュリティ（暗号化、アクセス制御、改ざん検知）
- ログの自動収集・転送（Lambda, Kinesis, Firehose等）
- アラート・通知設定（CloudWatchアラーム、SNS連携）
- ログのアーカイブ・バックアップ
- ログの統合管理（複数サービスのログを一元管理）
- Lambdaの非同期実行失敗時にSQS（DLQ）へイベントやエラーログを送信し、後続バッチや監視で処理するパターンも有効

---

必要に応じて、各項目の詳細や具体的な設定例も追記可能です。
