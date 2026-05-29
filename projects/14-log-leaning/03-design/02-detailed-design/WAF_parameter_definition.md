# WAF（Web Application Firewall）パラメータ定義

このファイルは、ALB配下のWebサービスを保護するためのAWS WAFパラメータ定義例です。

## 基本パラメータ

| パラメータ名         | 値例                      | 説明                                 |
|----------------------|---------------------------|--------------------------------------|
| Name                 | log-leaning-waf           | WAF名                                |
| Scope                | REGIONAL                  | グローバル or リージョナル           |
| ResourceType         | ALB                       | 保護対象リソース種別                 |
| ResourceArn          | log-leaning-alb           | 保護対象ALBのARN                     |
| Tags                 | Environment=dev等         | タグ                                 |

## ルール設定例

| パラメータ名         | 値例                      | 説明                                 |
|----------------------|---------------------------|--------------------------------------|
| RuleName             | AWS-AWSManagedRulesCommonRuleSet | AWSマネージドルールセット           |
| Priority             | 1                         | 評価順序                             |
| Action               | ALLOW/COUNT/BLOCK         | アクション                           |
| VisibilityConfig     | CloudWatchMetricsEnabled: true | メトリクス有効化                   |

## 備考
- ScopeはALBにアタッチする場合「REGIONAL」を指定。
- ルールはAWSマネージドルールセットを推奨。必要に応じてカスタムルールも追加可能。
- ResourceArnはALB作成後にARNを指定してください。
- WAFの詳細なルール設計は要件に応じて調整してください。
