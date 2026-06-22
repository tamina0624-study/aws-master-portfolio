# CICD Learning Project

## 概要

PythonアプリケーションとTerraformインフラを対象に、品質とセキュリティを担保したCI/CDパイプラインの構築学習プロジェクト。

GitHub ActionsによるPR時の自動テストとセキュリティチェック、本番段階的デプロイ（dev → stg → prod）を実装。

---

## 🎯 プロジェクト目標

| # | 目標 | 実装状況 |
|----|------|---------|
| 1 | PR時に品質チェックが自動実行される | ✅ CI で実装 |
| 2 | mainマージ時にdev環境へ自動デプロイ | ✅ CD で実装 |
| 3 | stg/prodは手動承認付きでデプロイ | ✅ Environment approval で実装 |
| 4 | 失敗時にロールバック手順が実施可能 | ✅ スクリプト・手順書で実装 |

---

## 📁 ディレクトリ構成

```
projects/17-cicd-pippeline/
├── app/                          # Pythonアプリケーション
│   ├── __init__.py
│   └── calculator.py             # サンプルモジュール
├── tests/                        # ユニットテスト
│   └── test_calculator.py
├── terraform/                    # インフラストラクチャコード
│   ├── providers.tf              # AWS provider設定
│   ├── variables.tf              # 変数定義
│   ├── main.tf                   # メインリソース
│   └── outputs.tf                # 出力値
├── scripts/                      # 自動化スクリプト
│   ├── apply-branch-protection.ps1   # ブランチ保護設定
│   ├── health_check.py              # デプロイ後ヘルスチェック
│   └── rollback.ps1                 # ロールバック手順
├── docs/                         # ドキュメント
│   ├── DEPLOYMENT_HEALTH_AND_ROLLBACK.md
│   ├── learning/
│   │   ├── LEARNING_SUMMARY.md
│   │   └── 学習したい内容
│   └── steps/
│       ├── step0_setup.md
│       └── step2_terraform_check.md
├── pyproject.toml                # Python設定（ruff, mypy, pytest）
├── requirements-dev.txt          # 開発依存パッケージ
└── README.md                     # このファイル

.github/workflows/
├── ci.yml                        # PR時のCI
└── cd.yml                        # mainマージ時のCD
```

---

## 🚀 実装内容

### Step 0: 前提準備 ✅
- ブランチ: `feature/cicd-bootstrap` で作業開始
- 対象ディレクトリ確定（app/tests/terraform）
- 環境変数定義（AWS_REGION: us-east-2）

### Step 1: Python品質チェック ✅
**ツール**
- `ruff`: Linting
- `mypy`: 型チェック
- `pytest`: ユニットテスト（カバレッジ 80%以上）

**実行コマンド（ローカル）**
```bash
ruff check .
ruff format --check .
mypy .
pytest
```

### Step 2: Terraform品質チェック ✅
**検証**
- `terraform fmt -check -recursive`
- `terraform validate`
- `terraform plan` (AWS認証必須)

**セキュリティスキャン**
- `checkov` で IaC セキュリティチェック

### Step 3: CI ワークフロー ✅
**ファイル**: [.github/workflows/ci.yml](.github/workflows/ci.yml)

**トリガー**: PR作成時（projects/17-cicd-pippeline 配下の変更）

**ジョブ**
1. `python-quality`: ruff + mypy
2. `python-test`: pytest + coverage 80%チェック
3. `security-scan`: pip-audit + gitleaks + checkov
4. `terraform-check`: fmt + validate + plan

**失敗時**: PR マージ不可

### Step 4: ブランチ保護 ✅
**必須ステータスチェック**
- python-quality
- python-test
- security-scan
- terraform-check

**実行方法**
```powershell
# Dry run
./projects/17-cicd-pippeline/scripts/apply-branch-protection.ps1 -DryRun

# 実際に適用（GitHub token 必須）
$env:GITHUB_TOKEN = "YOUR_TOKEN_WITH_ADMIN_PERMISSION"
./projects/17-cicd-pippeline/scripts/apply-branch-protection.ps1
```

### Step 5: CD ワークフロー ✅
**ファイル**: [.github/workflows/cd.yml](.github/workflows/cd.yml)

**トリガー**: main ブランチへの push

**デプロイフロー**
```
deploy-dev (自動)
    ↓
deploy-stg (承認待ち)
    ↓
deploy-prod (承認待ち)
```

**各環境で**
- Terraform init → validate → plan → apply
- ヘルスチェック実行（S3 バケット確認）

### Step 6: ヘルスチェック・ロールバック ✅
**自動ヘルスチェック** (CD内)
```python
# scripts/health_check.py
- S3 バケット存在確認
- バージョニング状態確認
- タグ付け確認
```

**ロールバック** (手動)
```powershell
./projects/17-cicd-pippeline/scripts/rollback.ps1 -Environment dev -DryRun
./projects/17-cicd-pippeline/scripts/rollback.ps1 -Environment dev
```

**詳細** → [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md)

---

## 🔧 セットアップ

### ローカル環境準備
```bash
cd projects/17-cicd-pippeline

# Python依存インストール
pip install -r requirements-dev.txt

# Terraform初期化
cd terraform
terraform init -backend=false
cd ..
```

### GitHub 設定

#### 1. Repository Variables 作成
```
AWS_ROLE_ARN = "arn:aws:iam::ACCOUNT:role/ROLE_NAME"
AWS_REGION = "us-east-2"
PYTHON_VERSION = "3.12"
```

#### 2. Environments 作成
- dev（自動デプロイ）
- stg（承認必須）
- prod（承認必須）

#### 3. ブランチ保護設定（ステップ4参照）

---

## ✅ チェックリスト（運用時）

### デプロイ前
- [ ] PR でコードレビュー完了
- [ ] CI パイプライン全通過
- [ ] `terraform plan` 差分を確認

### デプロイ中
- [ ] CD ワークフロー実行ログ監視
- [ ] 段階的デプロイ (dev → stg → prod) 進行確認

### デプロイ後
- [ ] ヘルスチェック PASS 確認
- [ ] AWS コンソール手動確認
- [ ] CloudWatch ログで異常確認

### トラブル時
- [ ] ロールバック手順実施
- [ ] 原因を記録（テンプレート: [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md) 参照）
- [ ] 改善案をチケット化

---

## 📚 ドキュメント

| ドキュメント | 内容 |
|-----------|------|
| [学習したい内容](./docs/learning/学習したい内容) | 全体計画（目的、ステップ、完了条件） |
| [LEARNING_SUMMARY.md](./docs/learning/LEARNING_SUMMARY.md) | 学習成果の最終まとめ |
| [step0_setup.md](./docs/steps/step0_setup.md) | 初期セットアップ内容 |
| [step2_terraform_check.md](./docs/steps/step2_terraform_check.md) | Terraform検証結果 |
| [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](./docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md) | ヘルスチェック・ロールバック手順 |

---

## 🔐 セキュリティ方針

- **シークレット**: リポジトリに保存しない。環境変数・GitHub Secrets を使用
- **認証**: OIDC（IAM role assume）で長期キーを回避
- **スコープ**: CI/CD実行ユーザーは最小権限（S3・Terraform state 操作のみ）

---

## 📊 CI/CD構成図

```
┌─────────────────────┐
│   Feature Branch    │
│  (pull_request)     │
└──────────┬──────────┘
           │
           ↓
   ┌───────────────────────────────────────────────┐
   │         CI Pipeline (.github/workflows/ci.yml)│
   ├───────────────────────────────────────────────┤
   │ 1. python-quality  (ruff, mypy)              │
   │ 2. python-test     (pytest, coverage)        │
   │ 3. security-scan   (pip-audit, gitleaks)     │
   │ 4. terraform-check (fmt, validate, plan)     │
   └───────────────────────────────────────────────┘
           │
         [Required Status Checks]
           │ (CI通過必須)
           ↓
   ┌──────────────────┐
   │  Code Review     │
   │  (Required: 1)   │
   └────────┬─────────┘
            │
            ↓
   ┌────────────────────────┐
   │   Merge to main        │
   │   (Fast-forward check) │
   └────────┬───────────────┘
            │
            ↓
   ┌───────────────────────────────────────────────┐
   │         CD Pipeline (.github/workflows/cd.yml)│
   ├───────────────────────────────────────────────┤
   │ deploy-dev (自動実行)                         │
   │   → terraform apply                          │
   │   → health check                             │
   │          ↓                                    │
   │ deploy-stg (承認待ち)                         │
   │   → terraform apply                          │
   │   → health check                             │
   │          ↓                                    │
   │ deploy-prod (承認待ち)                        │
   │   → terraform apply                          │
   │   → health check                             │
   └───────────────────────────────────────────────┘
            │
      [Success]
            ↓
   ┌────────────────────────────────┐
   │  All Environments Updated      │
   │  S3, CloudWatch Logs Ready     │
   └────────────────────────────────┘
```

---

## 🎓 学習成果

このプロジェクトで習得できる内容：
1. GitHub Actions による CI/CD パイプラインの設計と実装
2. Python コード品質・セキュリティチェックの自動化
3. Terraform のコード検証と段階的デプロイ
4. OIDC を使用した安全な AWS 認証
5. デプロイ後の検証・ロールバック手順
6. ブランチ保護・必須チェックの運用

---

## 📝 ライセンス

このプロジェクトはポートフォリオ学習用です。

---

## 🤝 サポート

問題が発生した場合は以下を確認してください：
- [DEPLOYMENT_HEALTH_AND_ROLLBACK.md](./docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md) - トラブルシューティング
- GitHub Actions 実行ログ - エラー詳細
- `terraform plan` 出力 - インフラ差分

---

**Last Updated**: 2026-06-21
