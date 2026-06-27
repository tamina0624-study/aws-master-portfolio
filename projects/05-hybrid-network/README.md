# 05 Hybrid Network

AWS とオンプレミス環境（EC2 で模擬）を Site-to-Site VPN + BGP で接続するハイブリッドネットワーク構成。
フェイルオーバーの検証まで含めた実践的な構成を Terraform で完全コード化している。

---

## ネットワーク構成図

```
┌─────────────────────────────┐      ┌──────────────────────────────┐
│        AWS VPC              │      │   オンプレミス VPC（模擬）      │
│  10.0.0.0/16                │      │   10.1.0.0/16                 │
│                             │      │                               │
│  ┌─────────────────────┐    │      │   ┌──────────────────────┐    │
│  │  Virtual Private    │    │      │   │  EC2 ルーター         │    │
│  │  Gateway (VGW)      │◀──IPsec──▶│   │  strongSwan (IPsec)  │    │
│  │                     │  Tunnel1  │   │  FRR (BGP)           │    │
│  │  AS: 64512          │◀──IPsec──▶│   │  AS: 65000           │    │
│  └─────────┬───────────┘  Tunnel2  │   └──────────────────────┘    │
│            │                       │                               │
│  ルートテーブル                     │   User Data で自動設定          │
│  （BGP 経路伝播）                   │                               │
└─────────────────────────────┘      └──────────────────────────────┘
         ↑
     BGP による経路自動学習
     オンプレ側 CIDR がルートテーブルに
     「伝播済み」として自動登録される
```

---

## 実装内容

### VPN 接続（vpn_aws.tf）
- Virtual Private Gateway (VGW) を作成し VPC にアタッチ
- Customer Gateway (CGW) にオンプレミス側 IP と BGP AS 番号を設定
- Site-to-Site VPN で **2本のIPsecトンネル** による冗長構成

### オンプレミス模擬ルーター（router_onprem.tf）
- EC2 インスタンスを BGP ルーターとして構成
- User Data で strongSwan (IPsec) と FRR (BGP) を自動インストール・設定
- BGP セッション確立後、経路情報が AWS 側ルートテーブルへ自動伝播

### フェイルオーバー検証
1. VPN トンネル 1 本をダウン
2. もう 1 本への通信切り替えを Ping で確認
3. BGP による経路再収束の確認

---

## ファイル構成

```
05-hybrid-network/
├── vpn_aws.tf          # VGW, CGW, VPN Connection（2トンネル）
├── vpc_onprem.tf       # オンプレミス模擬 VPC
├── router_onprem.tf    # EC2 ルーター（strongSwan + FRR）
├── data_aws.tf         # AMI データソース
├── providers.tf
├── variables.tf
├── outputs.tf
├── EC2_Setting/        # EC2 設定メモ
├── study_memo/         # BGP・VPN 学習メモ
└── templates/          # strongSwan 設定テンプレート
```

---

## 実行方法

```bash
terraform init
terraform plan
terraform apply

# VPN トンネル状態確認
aws ec2 describe-vpn-connections \
  --query 'VpnConnections[].VgwTelemetry'
```

---

## 設計のポイント

| 観点 | 実装内容 |
|------|---------|
| 冗長性 | 2本の IPsec トンネルで Active/Active |
| 動的ルーティング | BGP で経路を自動学習（静的設定不要） |
| 再現性 | EC2 + User Data でオンプレ環境もコード化 |
| 検証可能性 | フェイルオーバー手順をドキュメント化 |

---

## 技術スタック

- **AWS**: Virtual Private Gateway, Customer Gateway, Site-to-Site VPN
- **BGP**: FRR (Free Range Routing) によるダイナミックルーティング
- **IPsec**: strongSwan
- **IaC**: Terraform
