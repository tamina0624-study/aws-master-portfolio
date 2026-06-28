# ALB（Application Load Balancer）パラメータ定義

このファイルは、Webサービス用のALB（Application Load Balancer）のパラメータ定義例です。

## 基本パラメータ

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Name                     | log-learning-alb                   | ALB名                                |
| Type                     | application                       | ロードバランサー種別（ALB）          |
| Scheme                   | internet-facing                   | インターネット向け or internal       |
| Subnets                  | log-learning-public-subnet など    | 配置するサブネット（複数可）         |
| SecurityGroups           | log-learning-alb-sg                | アタッチするSGのID                   |
| IpAddressType            | ipv4                              | IPアドレスタイプ                     |
| Tags                     | Environment=dev など              | タグ                                 |

## リスナー設定例

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Protocol                 | HTTP                              | プロトコル                           |
| Port                     | 80                                | ポート番号                           |
| DefaultAction            | forward: log-learning-target-group | デフォルトアクション（ターゲットグループ）|

## ターゲットグループ設定例

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Name                     | log-learning-tg                    | ターゲットグループ名                 |
| Protocol                 | HTTP                              | プロトコル                           |
| Port                     | 80                                | ポート番号                           |
| TargetType               | instance                          | インスタンス or ip                   |
| HealthCheckPath          | /                                 | ヘルスチェックパス                   |
| Matcher                  | 200                               | 正常とみなすHTTPステータス           |

## 備考
- サブネットはパブリックサブネットを2つ以上指定するのが推奨です。
- セキュリティグループはALB用に新規作成（例: log-learning-alb-sg）を推奨。
- 必要に応じてHTTPSリスナーや証明書設定も追加してください。
