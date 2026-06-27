# CI/CD Pipeline Portfolio Project

![CI](https://img.shields.io/badge/CI-GitHub_Actions-2088FF?logo=github-actions&logoColor=white)
![CD](https://img.shields.io/badge/CD-Terraform_+_ECS-7B42BC?logo=terraform&logoColor=white)
![Security](https://img.shields.io/badge/Security-Multi_Layer-red?logo=shield&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?logo=python&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-ECR_/_ECS_/_S3-FF9900?logo=amazonaws&logoColor=white)

## 概要

**Pythonアプリケーション + Dockerコンテナ + Terraform IaC** を対象に、
ゼロから構築した本番を意識したCI/CDパイプラインのポートフォリオです。

- **CI**: PR 作成時に品質・セキュリティを自動チェック。問題があればマージ不可
- **CD**: main マージ時に `dev → stg → prod` 段階的デプロイ（stg/prod は手動承認）
- **Image CI/CD**: Docker イメージのビルド・多層セキュリティスキャン・ECR プッシュ・ECS デプロイ
- **セキュリティ**: コード・依存関係・IaC・コンテナを **5段階の多層防御** で検査

実装期間: 2026-06-21 〜 2026-06-27（約1週間）

---

## 🏗️ システム構成図

### Application & Image CI/CD

```
PR作成時
┌──────────────────────────────────────────────────────────────┐
│                    CI Pipeline                               │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ python-      │  │ python-test  │  │ security-scan      │ │
│  │ quality      │  │ pytest       │  │ pip-audit          │ │
│  │ ruff / mypy  │  │ coverage 80% │  │ gitleaks           │ │
│  └──────────────┘  └──────────────┘  │ checkov            │ │
│  ┌──────────────┐  ┌──────────────┐  └────────────────────┘ │
│  │ terraform-   │  │ image-ci     │                          │
│  │ check        │  │ Trivy FS/img │                          │
│  │ fmt/validate │  │ CodeQL SAST  │                          │
│  │ plan         │  └──────────────┘                          │
│  └──────────────┘                                            │
└──────────────────────────────────────────────────────────────┘
                    ↓ 全 job 通過 → マージ可

main マージ時
┌──────────────────────────────────────────────────────────────┐
│                    CD Pipeline                               │
│                                                              │
│  Terraform CD:                 Image CD:                     │
│  deploy-dev  (自動)            build & push ECR (自動)       │
│       ↓                        → ECS deploy dev (自動)       │
│  deploy-stg  (手動承認)                                      │
│       ↓                                                      │
│  deploy-prod (手動承認)                                      │
└──────────────────────────────────────────────────────────────┘
```

### セキュリティ多層防御

```
Layer 1 [コード段階]  pip-audit → 依存パッケージの既知脆弱性
                     gitleaks  → APIキー・シークレットの混入検出
                     checkov   → IaC のセキュリティ設定不備

Layer 2 [ビルド前]   Trivy FS  → requirements.txt の依存関係チェック

Layer 3 [ビルド後]   Trivy img → Debian OSパッケージの脆弱性検出

Layer 4 [SAST]      CodeQL    → Pythonコードの脆弱性・品質検出

Layer 5 [ランタイム] 非rootユーザー / readonly rootFS / ヘルスチェック
```

---

## ✅ 実装機能一覧

| カテゴリ | 項目 | 詳細 |
|---------|------|------|
| **CI** | Python品質チェック | ruff（lint/format）, mypy（型チェック）, pytest（coverage 80%以上） |
| **CI** | セキュリティスキャン | pip-audit, gitleaks, checkov |
| **CI** | Terraform検証 | fmt, validate, plan + checkov |
| **CI** | Image CI | Trivy FS/imageスキャン, CodeQL SAST |
| **CD** | Terraform デプロイ | dev自動 → stg/prod 手動承認の段階的デプロイ |
| **CD** | Image CD | ECRプッシュ（github.sha ユニークタグ）+ ECS Fargate デプロイ |
| **CD** | ヘルスチェック | S3バケット検証スクリプト（Python + boto3） |
| **CD** | ロールバック | 手動・自動シナリオ対応手順書 |
| **Infra** | AWS認証 | OIDC（長期アクセスキー不使用） |
| **Infra** | コンテナ | マルチステージ Dockerfile, python:3.14-slim, 非root |
| **Infra** | ECR | イミュータブルタグ, プッシュ時スキャン, ライフサイクルポリシー |
| **Infra** | ブランチ保護 | Required Status Checks, PR レビュー必須 |

---

## 📁 ディレクトリ構成

```
projects/17-cicd-pippeline/
├── app/
│   ├── server.py             # Flask Web アプリケーション
│   └── __init__.py
├── tests/
│   └── test_server.py        # pytest (カバレッジ 92%)
├── terraform/
│   ├── providers.tf          # AWS provider (OIDC認証)
│   ├── variables.tf          # 環境変数定義 (dev/stg/prod)
│   ├── main.tf               # S3, ECR, ECS リソース
│   └── outputs.tf
├── scripts/
│   ├── apply-branch-protection.ps1   # ブランチ保護設定（GitHub API）
│   ├── health_check.py              # デプロイ後ヘルスチェック
│   └── rollback.ps1                 # ロールバック手順
├── docs/
│   ├── DEPLOYMENT_HEALTH_AND_ROLLBACK.md
│   └── learning/
│       └── LEARNING_SUMMARY.md
├── Dockerfile                # マルチステージ / 非root / ヘルスチェック
├── pyproject.toml            # ruff, mypy, pytest 設定
├── requirements.txt          # Flask 等ランタイム依存
└── requirements-dev.txt      # テスト・品質チェック依存

.github/workflows/
├── ci.yml                    # PR時のCI（Python / Security / Terraform）
├── cd.yml                    # mainマージ時の段階的 Terraform デプロイ
├── image-ci.yml              # PR時のイメージビルド・セキュリティスキャン
└── image-cd.yml              # mainマージ時の ECRプッシュ・ECSデプロイ
```

---

## 🚀 CI パイプライン詳細

### 1. Python品質チェック（ci.yml）

```yaml
# PR 時に自動実行
jobs:
  python-quality:  # ruff lint + format チェック、mypy 型チェック
  python-test:     # pytest + カバレッジ 80% 閾値チェック
  security-scan:   # pip-audit + gitleaks + checkov
  terraform-check: # fmt + validate + plan
```

**ローカル実行コマンド**
```bash
ruff check .
ruff format --check .
mypy .
pytest --cov=app --cov-report=term-missing
```

### 2. イメージ CI（image-ci.yml）

```yaml
jobs:
  build-and-scan:
    - docker build           # マルチステージビルド
    - trivy fs .             # requirements.txt 依存関係スキャン
    - trivy image            # OSパッケージ脆弱性スキャン
  codeql-analysis:
    - CodeQL SAST            # Pythonコード静的解析
```

---

## 🚢 CD パイプライン詳細

### Terraform CD（cd.yml）

```
deploy-dev  ──→ terraform apply (自動)  ──→ health check
    ↓
deploy-stg  ──→ 手動承認  ──→ terraform apply  ──→ health check
    ↓
deploy-prod ──→ 手動承認  ──→ terraform apply  ──→ health check
```

### Image CD（image-cd.yml）

```
build-and-push:
  docker build
  → ECR push（タグ: github.sha ユニーク化）

deploy-to-ecs:
  needs: build-and-push
  → ECS サービス更新 (dev 環境)
```

---

## 🔐 セキュリティ設計のポイント

### AWS 認証（OIDC）

```
GitHub Actions
    ↓ JWT トークン発行
AWS STS AssumeRoleWithWebIdentity
    ↓ 一時的な認証情報（15分）
Terraform apply / ECR push / ECS deploy
```

長期アクセスキーを使わず、OIDC で一時的認証情報を取得する設計を採用。

### Dockerfile セキュリティ

```dockerfile
# マルチステージビルド（ビルド依存を本番イメージに含めない）
FROM python:3.14-slim AS builder
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.14-slim AS runtime
# 非rootユーザーで実行
RUN groupadd -g 1001 appgroup && useradd -u 1001 -g appgroup appuser
USER appuser

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost:5000/health
```

### 本番環境の保護設計

- `lifecycle { prevent_destroy = true }` でS3・DBの誤削除を防止
- stg/prod は **必ず手動承認** を通す（自動 apply 禁止）
- ECR イミュータブルタグで意図しない上書きを防止
- `github.sha` をタグに使用し、デプロイ済みイメージを一意に追跡

---

## 🛠️ 実際に解決したトラブル（11件）

実装中に発生した問題と対策の記録。

| # | 問題 | 根本原因 | 対策 |
|---|------|---------|------|
| 1 | CD がスキップされる | Repository Variables 未設定 | Variables と Environment を正しく設定 |
| 2 | OIDC 認証失敗 | IAM 信頼ポリシーの `sub` 条件が厳しすぎ | `StringLike` + リポジトリスコープに調整 |
| 3 | cd.yml 構文エラー | BOM付きUTF-8・インデント崩れ | BOMなしUTF-8、インデント全面修正 |
| 4 | ruff I001 エラー | import 並び順が規約不一致 | stdlib/third-party 区切りを空行で統一 |
| 5 | mypy boto3 型エラー | 運用スクリプトが型チェック対象に混入 | `pyproject.toml` でスコープを分離 |
| 6 | Terraform init 失敗 | 同一 `data` ブロックが重複定義 | 重複削除、`terraform validate` を CI に追加 |
| 7 | S3 409 エラー | state と実リソースの不整合 | `terraform import` で state を同期 |
| 8 | ヘルスチェック 403 | Actions ロールの S3 権限不足 | List/Get/Tagging 権限をロールポリシーに追加 |
| 9 | aws_s3_bucket_tagging 非対応 | provider バージョンとリソースが非対応 | 該当リソースを外し CLI 側で処理 |
| 10 | ECR latest タグ 409 | イミュータブルタグで上書き禁止 | `github.sha` をユニークタグとして使用 |
| 11 | Trivy で脆弱性多数検出 | python:3.12-slim のパッケージが古い | python:3.14-slim に更新 |

> エラーメッセージから根本原因を特定し、再発防止策まで設計する実践的な経験を積みました。

---

## 🔧 ローカルセットアップ

```bash
cd projects/17-cicd-pippeline

# Python 依存インストール
pip install -r requirements-dev.txt

# Terraform 初期化
cd terraform && terraform init -backend=false && cd ..

# ローカルで品質チェック
ruff check . && ruff format --check .
mypy .
pytest --cov=app
```

### GitHub 設定

```
# Repository Variables
AWS_ROLE_ARN = "arn:aws:iam::ACCOUNT:role/ROLE_NAME"
AWS_REGION   = "us-east-2"
ECR_REPO_URI = "ACCOUNT.dkr.ecr.us-east-2.amazonaws.com/app"

# Environments（Approvers を設定）
dev   → 自動デプロイ
stg   → 承認必須
prod  → 承認必須
```

```powershell
# ブランチ保護設定
$env:GITHUB_TOKEN = "YOUR_TOKEN"
./scripts/apply-branch-protection.ps1
```

---

## ✅ デプロイチェックリスト

### デプロイ前
- [ ] PR の CI 全 job 通過確認
- [ ] `terraform plan` 差分レビュー（想定外の削除がないか）
- [ ] セキュリティスキャン結果確認（Trivy / CodeQL）

### デプロイ中
- [ ] CD ワークフロー実行ログ監視
- [ ] dev → stg → prod の段階的進行確認

### デプロイ後
- [ ] ヘルスチェック PASS 確認
- [ ] ECS サービスが新しいタスク定義で起動しているか確認
- [ ] CloudWatch ログで異常確認

### トラブル時
- [ ] ロールバック手順実施 → [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md)
- [ ] 原因・対策を記録

---

## 🛠️ 技術スタック

```
CI/CD
├── GitHub Actions (ワークフロー設計・Environment approval・OIDC)
└── ブランチ保護 (Required Status Checks)

AWS
├── ECR   (コンテナイメージリポジトリ・イミュータブルタグ)
├── ECS   (Fargate デプロイ)
├── S3    (Terraform state・デプロイターゲット)
├── IAM   (OIDC 連携・最小権限)
└── CloudWatch (ログ監視)

IaC
└── Terraform (マルチ環境: dev/stg/prod・変数分離)

コンテナ
└── Docker (マルチステージビルド・python:3.14-slim・非root)

セキュリティスキャン
├── Trivy      (FS + イメージスキャン)
├── CodeQL     (SAST)
├── pip-audit  (依存パッケージ脆弱性)
├── gitleaks   (シークレット漏えい検出)
└── checkov    (IaC セキュリティ)

Python
├── Flask      (Web アプリケーション)
├── ruff       (Lint + Format)
├── mypy       (型チェック)
└── pytest     (テスト・カバレッジ 92%)
```

---

## 📊 学習成果サマリー

| 領域 | 習得内容 |
|------|---------|
| GitHub Actions | ワークフロー設計・シークレット管理・Environment approval・OIDC |
| コンテナセキュリティ | マルチステージビルド・非root・ヘルスチェック・イミュータブルタグ |
| セキュリティスキャン | Trivy（FS+image）・CodeQL・pip-audit・gitleaks・checkov の多層防御 |
| AWS | ECR / ECS / S3 / IAM（OIDC）の実践構築 |
| Terraform | マルチ環境構成・checkov 連携・state 管理 |
| Python | Flask / ruff / mypy / pytest (coverage 92%) |
| 運用設計 | 段階的デプロイ・ロールバック戦略・ヘルスチェック設計 |

詳細な学習記録: [LEARNING_SUMMARY.md](docs/learning/LEARNING_SUMMARY.md)

---

## 📚 参照ドキュメント

| ドキュメント | 内容 |
|-----------|------|
| [LEARNING_SUMMARY.md](docs/learning/LEARNING_SUMMARY.md) | 学習成果・トラブル記録・習得技術の詳細まとめ |
| [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md) | ヘルスチェック・ロールバック手順 |

---

**Last Updated**: 2026-06-27
