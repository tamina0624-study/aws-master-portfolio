# ALB（Application Load Balancer）パラメータ定義

このファイルは、Webサービス用のALB（Application Load Balancer）のパラメータ定義例です。

## 基本パラメータ

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Name                     | log-leaning-alb                   | ALB名                                |
| Type                     | application                       | ロードバランサー種別（ALB）          |
| Scheme                   | internet-facing                   | インターネット向け or internal       |
| Subnets                  | log-leaning-public-subnet など    | 配置するサブネット（複数可）         |
| SecurityGroups           | log-leaning-alb-sg                | アタッチするSGのID                   |
| IpAddressType            | ipv4                              | IPアドレスタイプ                     |
| Tags                     | Environment=dev など              | タグ                                 |

## リスナー設定例

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Protocol                 | HTTP                              | プロトコル                           |
| Port                     | 80                                | ポート番号                           |
| DefaultAction            | forward: log-leaning-target-group | デフォルトアクション（ターゲットグループ）|

## ターゲットグループ設定例

| パラメータ名             | 値例                              | 説明                                 |
|--------------------------|-----------------------------------|--------------------------------------|
| Name                     | log-leaning-tg                    | ターゲットグループ名                 |
| Protocol                 | HTTP                              | プロトコル                           |
| Port                     | 80                                | ポート番号                           |
| TargetType               | instance                          | インスタンス or ip                   |
| HealthCheckPath          | /                                 | ヘルスチェックパス                   |
| Matcher                  | 200                               | 正常とみなすHTTPステータス           |

## 備考
- サブネットはパブリックサブネットを2つ以上指定するのが推奨です。
- セキュリティグループはALB用に新規作成（例: log-leaning-alb-sg）を推奨。
- 必要に応じてHTTPSリスナーや証明書設定も追加してください。
