# Lambda詳細設計：パラメータ定義

| パラメータ名         | 値                        | 説明                                 |
|----------------------|---------------------------|--------------------------------------|
| 関数名               | log-leaning-log-handler   | ログ処理用Lambda関数名               |
| ランタイム           | python3.12                | 使用するランタイム                   |
| メモリサイズ         | 256MB                     | Lambda関数のメモリ割当               |
| タイムアウト         | 30秒                      | 最大実行時間                         |
| ハンドラー           | handler.lambda_handler     | エントリポイント                     |
| 環境変数             | LOG_BUCKET=log-leaning-logs| S3バケット名など                     |
| VPC設定              | log-leaning-vpc           | 必要に応じてVPC内配置                |
| IAMロール            | log-leaning-lambda-role   | 必要な権限を付与したIAMロール         |
| トリガー             | API Gateway                | REST API/HTTP API経由でLambdaを実行    |
| タグ                 | Name=log-leaning-log-handler| 識別用タグ                        |

---

※要件に応じてメモリ・タイムアウト・環境変数・トリガー等を調整してください。
