# 10 Hybrid Cloud Connectivity and Security Automation

AWS VPC とオンプレミス模擬 VPC を VPN で接続し、GuardDuty・WAF・Lambda による自律防御を組み合わせた統合セキュリティ構成。
ネットワーク接続・脅威検知・自動遮断までを Terraform でコード化している。

---

## 全体構成図

```
┌──────────────────────────────────────────────────────────────────┐
│                       AWS VPC (10.0.0.0/16)                      │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │  WAF v2                                                 │     │
│  │  ・Allow IP Set  (AWS/オンプレ内部 CIDR)                │     │
│  │  ・Deny IP Set   (GuardDuty 検知 IP → 自動追加)         │     │
│  └─────────────────────┬───────────────────────────────────┘     │
│                        │ フィルタリング                           │
│                        ▼                                         │
│  ┌─────────┐    ┌─────────────┐    ┌──────────────────────────┐  │
│  │ Internet │   │     ALB      │   │  EC2 Web サーバー         │  │
│  │ Gateway  │──▶│             │──▶│  (Ubuntu / Amazon Linux) │  │
│  └─────────┘    └─────────────┘    └──────────────────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │  GuardDuty                                              │     │
│  │                    ┌─────────────────┐                  │     │
│  │  脅威検知          │  EventBridge     │                  │     │
│  │  ───────────────▶  │  PortProbeAction │──▶ Lambda        │     │
│  │                    └─────────────────┘    │             │     │
│  └────────────────────────────────────────────┼────────────┘     │
│                                               │                  │
│                                       WAF Deny IP Set に追加     │
│                                                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                   IPsec VPN (2トンネル冗長)
                           │
┌──────────────────────────┴───────────────────────────────────────┐
│                  オンプレミス VPC（模擬 / 10.1.0.0/16）            │
│                                                                  │
│  ┌──────────────────────┐                                        │
│  │  EC2 VPN ルーター    │  strongSwan (IPsec) + FRR (BGP)        │
│  │  AS: 65000           │  User Data で自動設定                   │
│  └──────────────────────┘                                        │
└──────────────────────────────────────────────────────────────────┘
```

---

## 自動遮断フロー

```
GuardDuty 検知
    │ PortProbeAction イベント
    ▼
EventBridge ルール
    │ Lambda を起動
    ▼
Lambda 関数
    │ 攻撃元 IP を抽出 → WAF Deny IP Set へ追加
    ▼
WAF が次のリクエストから自動ブロック
```

---

## 実装モジュール

| モジュール | 内容 |
|-----------|------|
| `modules/vpc` | AWS 側 VPC・サブネット・ルートテーブル |
| `modules/vpn` | VGW・CGW・Site-to-Site VPN（2トンネル） |
| `modules/ec2` | Web サーバー・オンプレ模擬ルーター |
| `modules/guardduty` | GuardDuty + EventBridge ルール |
| `modules/waf` | WAF v2 + Allow/Deny IP セット |
| `modules/lambda` | 自動 IP ブロック Lambda |
| `modules/security_group` | NACL・SG の役割分担設計 |

---

## ファイル構成

```
10-Hybrid-Cloud-Connectivity-and-Security-Automation/
├── 01-Specification/   # 要件・仕様書
├── 02-architecture/    # 構成図
├── 03-terraform/       # Terraform コード（モジュール分割）
│   ├── main.tf
│   ├── modules/
│   │   ├── vpc/ vpn/ ec2/ guardduty/ waf/ lambda/ security_group/
│   └── variables.tf / outputs.tf
└── 04-Conclude/        # 学習まとめ・振り返り
```

---

## 実装中に得た知見

- WAF・NACL・SG の役割分担（動的 IP ブロックは WAF、ネットワーク層制御は NACL/SG）
- GuardDuty はパブリック IP アドレス間の通信を対象とするため、プライベート IP 模擬攻撃では検知されない
- Terraform で管理する環境を先に手動で構築すると State との乖離が発生しやすい
- エフェメラルポート（1024-65535）を SG/NACL で許可しないと戻りパケットが届かない
- AWS ネットワークは仮想的に冗長化されているため、オンプレのようなインターフェース冗長は不要

---

## 実行方法

```bash
cd 03-terraform
terraform init
terraform plan
terraform apply
```

---

## 技術スタック

- **AWS**: VPC, VPN, GuardDuty, WAF v2, Lambda, ALB, EC2
- **VPN**: strongSwan (IPsec) + FRR (BGP)
- **IaC**: Terraform（モジュール分割）
- **自動化**: EventBridge → Lambda による自律防御
