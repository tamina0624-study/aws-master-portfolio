# AWSログ学習用 サービス作成一覧（基本設計）

## 作成対象サービス一覧
- EC2（仮想サーバ）
- S3（ストレージバケット）
- Lambda（サーバレス関数）
- API Gateway（API公開）
- VPC（ネットワーク）
- RDS/Aurora（データベース）
- ELB（ロードバランサー）
- Route53（DNS）
- WAF（Web Application Firewall）


- GuardDuty（脅威検知）
- CloudTrail（操作履歴）
- CloudWatch Logs（ログ集約・可視化）
- VPCエンドポイント（Interface/Gateway Endpoint）
- SQS（メッセージキューのイベントログやDLQ）
- SNS（通知ログ）
- CloudFront（アクセスログ）
- Step Functions（実行履歴ログ）
- EventBridge（イベントバスのログ）
- EFS/EBS（ファイルシステム/ブロックストレージのアクセスログ）
- Cognito（認証・認可イベントログ）
- SSM（セッションマネージャやコマンド実行ログ）
- Code系サービス（CodeBuild/CodeDeploy/CodePipeline等のビルド・デプロイログ）
- Inspector/Security Hub（セキュリティ診断・集約ログ）
- Control Tower（ガバナンスログ）
- Backup（バックアップ操作ログ）

---

この一覧をもとに、各サービスのログ出力設定・命名規則・保存期間・タグ設計などを具体化していきます。

---

## ログ検索用タグ設計

### 設計方針
- AWSリソースに共通のタグを付与し、ログ検索や運用管理を効率化する
- ログの発生元や用途、重要度、担当者などで分類できるようにする

### 推奨タグキー例
| タグキー         | 用途例                         |
|------------------|--------------------------------|
| LogGroup         | ロググループ名、用途分類       |
| LogType          | アクセス/監査/操作/エラー等     |
| System           | システム名、プロジェクト名      |
| Env              | 環境（prod/dev/stg等）         |
| Owner            | 担当者やチーム名               |
| Importance       | 重要度（high/medium/low等）    |
| Retention        | 保存期間（例: 90d, 1y）        |

### タグ設計例
```
LogGroup    = "cloudtrail"
LogType     = "audit"
System      = "log-leaning"
Env         = "dev"
Owner       = "infra-team"
Importance  = "high"
Retention   = "365d"
```


### 備考
- タグはAWS標準のタグ機能で一括付与・検索が可能
- CloudWatch LogsやS3バケット、Lambda等にも同様のタグ付与を推奨
- タグ運用ルールは組織の管理方針に合わせて調整

---

## ELB（Elastic Load Balancer）パラメーター定義

| パラメーター名             | 説明                                 | 例・選択肢                          |
|---------------------------|--------------------------------------|-------------------------------------|
| Name                      | ELBの名前                            | my-app-elb                         |
| Type                      | ELBの種類                            | application / network / gateway    |
| Scheme                    | スキーム（公開/内部）                | internet-facing / internal         |
| Subnets                   | 配置するサブネット                   | subnet-xxxx, subnet-yyyy           |
| Security Groups           | アタッチするセキュリティグループ      | sg-xxxxxxx                         |
| Listeners                 | リスナー設定（プロトコル/ポート）     | HTTP:80, HTTPS:443                 |
| Target Group              | ターゲットグループ名                  | my-app-tg                          |
| Health Check Protocol     | ヘルスチェックのプロトコル            | HTTP / HTTPS / TCP                 |
| Health Check Path         | ヘルスチェックのパス                  | /health                            |
| Health Check Interval     | ヘルスチェック間隔（秒）              | 30                                 |
| Healthy Threshold         | 正常判定のしきい値                    | 3                                  |
| Unhealthy Threshold       | 異常判定のしきい値                    | 3                                  |
| Timeout                  | タイムアウト（秒）                    | 5                                  |
| Deregistration Delay      | 登録解除遅延（秒）                    | 300                                |
| Access Logs               | アクセスログの有効化/保存先           | 有効/無効、S3バケット名            |
| Cross-Zone Load Balancing | クロスゾーン負荷分散の有効化          | 有効/無効                          |
| Idle Timeout              | アイドルタイムアウト（秒）            | 60                                 |
| Tags                      | タグ                                  | Key: Value                         |

---

この表をもとに、ELBの設計・構築パラメーターを具体化してください。
