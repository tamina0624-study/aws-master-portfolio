# AWS側VPCとVPN Gatewayの詳細設計

## システム概要（ユースケース）
オンプレミス側（疑似VPC）のEC2インスタンスから、AWS側VPCに配置したデータベース（例：RDSやEC2上のDB）へセキュアにアクセスし、社内データを利用できるシステムとする。

### 主なポイント
- オンプレ側EC2からAWS DBへのプライベート接続（インターネット経由せずVPN経由のみ）
- AWS側DBはプライベートサブネットに配置し、外部公開しない
- 必要に応じて、オンプレ→AWS間のファイル転送やバッチ処理も想定

この構成により、社内システムのクラウド連携や段階的なクラウド移行の実践例としてアピールできる

## 1. VPC設計
- CIDRブロック例：10.0.0.0/16
- サブネット：
  - パブリックサブネット（10.0.1.0/24, 10.0.2.0/24）
  - プライベートサブネット（10.0.11.0/24, 10.0.12.0/24）
- AZ分散：2つ以上のAZに配置
- インターネットゲートウェイ：必要に応じてアタッチ

## 2. VPN Gateway設計
- VPN Gateway（VGW）をVPCにアタッチ
- ルートテーブルにVGW経由のルートを追加

## 3. Customer Gateway設計
- オンプレ側のグローバルIPを指定
- BGP ASN（例：65000）を指定

## 4. VPN Connection設計
- Site-to-Site VPN（ipsec.1）
- トンネル2本（冗長化）
- BGP有効化（推奨）
- Pre-Shared Key（自動生成または指定）

## 5. ルートテーブル設計
- オンプレ側宛のルートをVGW経由で追加
- 必要に応じてBGPで動的伝播

---

## Terraform管理リソース一覧
- aws_vpc
- aws_subnet
- aws_internet_gateway
- aws_vpn_gateway
- aws_vpn_gateway_attachment
- aws_customer_gateway
- aws_vpn_connection
- aws_vpn_connection_route
- aws_route_table
- aws_route

---

## 変数例（variables.tf）
```hcl
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { default = ["10.0.11.0/24", "10.0.12.0/24"] }
variable "azs" { default = ["ap-northeast-1a", "ap-northeast-1c"] }
variable "customer_gateway_ip" { description = "オンプレ側グローバルIP" }
variable "customer_gateway_bgp_asn" { default = 65000 }
```
