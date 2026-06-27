# 04 Enterprise Landing Zone

エンタープライズ環境を想定した AWS セキュリティ基盤のコード化。
CloudTrail・KMS・IAM Permissions Boundary・自動修復 Lambda を Terraform で一括構築する。

---

## 構成概要

```
┌─────────────────────────────────────────────────────┐
│                 AWS アカウント                        │
│                                                     │
│  ┌──────────────┐    暗号化     ┌────────────────┐  │
│  │  CloudTrail  │─────────────▶│   KMS キー     │  │
│  │ (全リージョン) │              │ (ログ保護用)   │  │
│  └──────┬───────┘              └────────────────┘  │
│         │ ログ書き込み                                │
│         ▼                                           │
│  ┌──────────────┐                                   │
│  │  S3 バケット │ ← パブリックアクセス完全ブロック     │
│  │（改ざん検知付）│   ログファイル検証 有効            │
│  └──────────────┘                                   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │           IAM Permissions Boundary           │   │
│  │  ・CloudTrail 停止/削除 → 常時 Deny          │   │
│  │  ・S3 パブリック化       → 常時 Deny          │   │
│  │  ・KMS キー削除          → 常時 Deny          │   │
│  │  ・Boundary 自体の変更   → 常時 Deny          │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  EventBridge ──▶ Lambda ──▶ S3 アクセス制御修復     │
└─────────────────────────────────────────────────────┘
```

---

## 実装内容

### CloudTrail（cloudtrail.tf）
- 全リージョン・グローバルサービスイベント記録
- KMS によるログ暗号化
- ログファイル整合性検証 (`enable_log_file_validation = true`)

### IAM Permissions Boundary（iam_boundary.tf）
- 開発者ロールに Boundary を強制アタッチ
- PowerUserAccess を付与しても、Boundary 定義の Deny は上書きできない
- `DenyBoundaryModification` で Boundary 自体の削除・変更も防止

```
開発者ロール
├── PowerUserAccess（広い権限）
└── Boundary（上限を設定）
    ├── AllowAll（Boundary 内はすべて許可）
    ├── Deny: CloudTrail停止/S3削除/KMS削除
    └── Deny: Boundary の変更・削除
```

### KMS（kms.tf）
- CloudTrail ログ専用の Customer Managed Key
- キーポリシーで使用可能なサービス・アカウントを制限

### 自動修復 Lambda（remediation.tf）
- EventBridge ルールで S3 の意図しない設定変更を検知
- 検知時に Lambda を起動してパブリックアクセスブロックを自動復元

---

## ファイル構成

```
04-enterprise-landing-zone/
├── cloudtrail.tf       # CloudTrail（マルチリージョン・ログ検証）
├── iam_boundary.tf     # Permissions Boundary + 開発者ロール
├── kms.tf              # Customer Managed KMS Key
├── s3.tf               # ログ保存バケット（パブリックアクセスブロック）
├── remediation.tf      # 自動修復 Lambda + EventBridge
├── providers.tf
├── variables.tf
└── architecture.html   # 構成図（HTML）
```

---

## 実行方法

```bash
terraform init
terraform plan
terraform apply
```

---

## 設計のポイント

| 観点 | 実装方法 |
|------|---------|
| 監査ログの保護 | KMS 暗号化 + ログファイル整合性検証 |
| 権限の上限設定 | Permissions Boundary で Deny を強制 |
| 設定変更への対応 | EventBridge + Lambda による自動修復 |
| ガードレールの堅牢性 | Boundary 自体の削除を Deny で保護 |
