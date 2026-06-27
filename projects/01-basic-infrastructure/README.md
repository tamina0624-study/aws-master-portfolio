# 01 Basic Infrastructure

AWS の基本インフラを Terraform のモジュール構成でコード化した。
VPC・サブネット・EC2・S3 を再利用可能なモジュールとして実装している。

---

## 構成図

```
┌──────────────────────────────────────────────┐
│                 AWS VPC                      │
│                                              │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │  Public Subnet  │  │  Private Subnet  │  │
│  │                 │  │                  │  │
│  │  ┌───────────┐  │  │  ┌───────────┐  │  │
│  │  │  EC2      │  │  │  │  EC2      │  │  │
│  │  │  (Web)    │  │  │  │  (App)    │  │  │
│  │  └───────────┘  │  │  └───────────┘  │  │
│  └─────────────────┘  └──────────────────┘  │
│                                              │
│  IGW / Route Table / Security Group          │
└──────────────────────────────────────────────┘
                    │
            ┌───────┴───────┐
            │   S3 バケット  │
            │ (ログ・静的    │
            │  コンテンツ)   │
            └───────────────┘
```

---

## ファイル構成

```
01-basic-infrastructure/
├── main.tf          # モジュール呼び出し
├── variables.tf     # 変数定義
├── outputs.tf       # 出力値
└── modules/
    ├── vpc/         # VPC・サブネット・IGW・ルートテーブル
    ├── ec2/         # EC2・キーペア・Security Group
    └── s3/          # S3 バケット・バケットポリシー
```

---

## 実装内容

### VPC モジュール
- VPC、パブリック/プライベートサブネット
- Internet Gateway とルートテーブル

### EC2 モジュール
- Security Group（SSH: 特定 IP のみ、HTTP: 全公開）
- AMI は変数で切り替え可能

### S3 モジュール
- パブリックアクセスブロック有効
- バージョニング設定対応

---

## 実行方法

```bash
terraform init
terraform plan
terraform apply
```

---

## 技術スタック

- **IaC**: Terraform（モジュール分割）
- **AWS**: VPC, EC2, S3, IGW, Security Group
