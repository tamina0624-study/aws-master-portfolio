# ハイブリッド・クラウド接続とセキュリティ自動化

このディレクトリは、AWSとオンプレミス（疑似VPC）をVPNで接続し、GuardDuty・WAF・Lambdaによる自律防御を実現するTerraform構成例です。

## ディレクトリ構成
- main.tf
- variables.tf
- outputs.tf
- modules/
    - vpc/
    - vpn/
    - guardduty/
    - waf/
    - lambda/
