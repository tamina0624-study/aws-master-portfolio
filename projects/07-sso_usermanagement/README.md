# 07 SSO / User Management

---

> 「退職した社員の AWS アクセス権が 3 ヶ月間残ったままだった。
> 監査で指摘されて初めて気づいた。アカウントが複数あって管理しきれていない。」

> 「異動のたびに、各 AWS アカウントを個別に設定変更している。
> 設定漏れが頻発していて、余計な権限が残り続けている。」

複数の AWS アカウントを持つ組織でよく起きるこの問題を解決するのが **AWS IAM Identity Center（旧 SSO）** です。
「どのユーザーが・どのアカウントに・どんな権限で」アクセスできるかを 1 箇所で管理でき、退職者のアクセスも即時に全アカウントで失効できます。
**Permission Set** でロールを設計し、グループ単位で割り当てる方式にすると、異動時の変更はグループの付け替えだけで完了します。
Terraform でコード化すれば、権限設定がレビュー可能・再現可能になり、設定漏れのリスクを大幅に減らせます。

本プロジェクトは、その IAM Identity Center によるユーザー管理と権限ライフサイクルを設計・実装した学習成果です。

## 解説動画

[![YouTube](https://img.shields.io/badge/YouTube-解説動画-FF0000?logo=youtube&logoColor=white)](https://youtu.be/OqYcPcz9Upg?si=-XXevE1bNgC1wp0n)

---

AWS IAM Identity Center（旧 SSO）を Terraform でコード化し、エンタープライズ基準の ID・アクセス管理を実践した。
ユーザー・グループ・Permission Set の設計から、入社・異動・退職のライフサイクル管理まで設計している。

---

## 構成概要

```
┌────────────────────────────────────────────────────────┐
│              IAM Identity Center                       │
│                                                        │
│  ┌──────────────────┐    ┌────────────────────────┐   │
│  │  ユーザー / グループ │    │   Permission Sets      │   │
│  │                  │    │                        │   │
│  │  - 開発チーム    │    │  - Developer           │   │
│  │  - 運用チーム    │    │    (EC2/S3 のみ)        │   │
│  │  - 管理者       │────▶│  - Ops                 │   │
│  └──────────────────┘    │    (CloudWatch/SSM)     │   │
│                          │  - Admin               │   │
│                          │    (ReadOnly + 特定 ops)│   │
│                          └────────────────────────┘   │
│                                    │                   │
│                                    ▼ アカウント割り当て  │
│                          ┌────────────────────────┐   │
│                          │  AWS アカウント          │   │
│                          │  (Organizations 管理下) │   │
│                          └────────────────────────┘   │
└────────────────────────────────────────────────────────┘
```

---

## 権限ライフサイクル設計

```
入社
  │  グループへの追加 → 必要な Permission Set が自動付与
  ▼

異動
  │  旧グループから削除 → 旧権限を失効
  │  新グループへ追加  → 新権限を付与
  ▼
  ※ グループ単位で管理するため、個別変更より設定漏れが起きにくい

退職
  │  ユーザーを無効化（削除ではなく無効化）
  │  → 全アカウントへのアクセスが即座に失効
  ▼
  ※ Identity Center で一元管理するため、個別アカウントを触る必要がない
```

---

## Terraform 実装内容

### sso.tf
- `aws_identitystore_user` ... ユーザー定義
- `aws_identitystore_group` ... グループ定義
- `aws_identitystore_group_membership` ... ユーザー・グループ紐付け
- `aws_ssoadmin_permission_set` ... Permission Set（ロール相当）の定義
- `aws_ssoadmin_managed_policy_attachment` ... AWS 管理ポリシーの付与
- `aws_ssoadmin_account_assignment` ... アカウントへの割り当て

---

## ファイル構成

```
07-sso_usermanagement/
├── README.md
├── sso.tf                    # メイン実装
├── SSOやりたかったこと.tf     # 試みた追加機能
├── providers.tf
├── SSOやりたかったことまとめ.md  # Organizations 権限制限での実施内容
├── SSO学習まとめ.md           # 設計パターン・実務ポイント
└── 権限ライフサイクル設計.md   # 入社・異動・退職シナリオ
```

---

## 設計のポイント

| 観点 | 実装内容 |
|------|---------|
| 一元管理 | Identity Center 1 箇所でユーザー管理、全アカウントに反映 |
| グループ単位の権限付与 | 個人ではなくグループに Permission Set を割り当て |
| 退職対応 | ユーザー無効化で全アカウントのアクセスを即時失効 |
| 最小権限 | Permission Set でサービス・操作を限定 |

---

## 実行方法

```bash
terraform init
terraform plan
terraform apply
```

---

## 学習メモ

- Organizations の権限が制限されている環境では、一部機能（アカウント割り当て等）を試すことができなかった
- 詳細は [SSOやりたかったことまとめ.md](SSOやりたかったことまとめ.md) を参照
