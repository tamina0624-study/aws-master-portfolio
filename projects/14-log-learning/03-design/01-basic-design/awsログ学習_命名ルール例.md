# AWSログ学習用 各サービスの命名ルール例

| サービス | ロググループ/バケット名例 | 備考 |
|---|---|---|
| EC2 | /log-learning/dev/ec2/ | CloudWatch Logsグループ名例 |
| S3 | log-learning-dev-s3-logs | S3バケット名例（バケット名は一意） |
| Lambda | /log-learning/dev/lambda/ | CloudWatch Logsグループ名例 |
| API Gateway | /log-learning/dev/apigw/ | CloudWatch Logsグループ名例 |
| VPC | /log-learning/dev/vpcflow/ | VPC Flow Logs用グループ名例 |
| RDS/Aurora | /log-learning/dev/rds/ | CloudWatch LogsまたはS3バケット名 |
| ELB | log-learning-dev-elb-logs | S3バケット名例 |
| Route53 | log-learning-dev-route53-logs | S3バケット名例（クエリログ等） |
| WAF | /log-learning/dev/waf/ | CloudWatch LogsまたはS3バケット名 |
| GuardDuty | log-learning-dev-guardduty-logs | S3バケット名例 |
| CloudTrail | log-learning-dev-cloudtrail-logs | S3バケット名例 |
| CloudWatch Logs | /log-learning/dev/custom/ | カスタムログ用グループ名例 |
| VPCエンドポイント | /log-learning/dev/vpcendpoint/ | CloudWatch LogsまたはS3バケット名 |
| SQS | /log-learning/dev/sqs/ | CloudWatch LogsまたはS3バケット名 |
| SNS | /log-learning/dev/sns/ | CloudWatch LogsまたはS3バケット名 |
| CloudFront | log-learning-dev-cloudfront-logs | S3バケット名例 |
| Step Functions | /log-learning/dev/stepfunctions/ | CloudWatch Logsグループ名例 |
| EventBridge | /log-learning/dev/eventbridge/ | CloudWatch Logsグループ名例 |
| EFS/EBS | log-learning-dev-efs-logs | S3バケット名例 |
| Cognito | /log-learning/dev/cognito/ | CloudWatch Logsグループ名例 |
| SSM | /log-learning/dev/ssm/ | CloudWatch Logsグループ名例 |
| Code系サービス | /log-learning/dev/codebuild/ など | サービスごとに分ける |
| Inspector/Security Hub | log-learning-dev-security-logs | S3バケット名例 |
| Control Tower | log-learning-dev-controltower-logs | S3バケット名例 |
| Backup | log-learning-dev-backup-logs | S3バケット名例 |

---

命名規則は組織標準やAWS命名制約も考慮して調整してください。
