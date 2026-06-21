# 学習成果まとめ

## プロジェクト完成日

2026-06-21

## 実装概要

CI/CDパイプラインをゼロから構築し、以下の機能を実装しました：

### ✅ 実装完了項目

| 項目 | 内容 | 参照ファイル |
|------|------|-----------|
| **CI** | PR時の自動テスト・セキュリティチェック | `.github/workflows/ci.yml` |
| **CD** | mainマージ時の段階的デプロイ（dev→stg→prod） | `.github/workflows/cd.yml` |
| **Python品質チェック** | ruff, mypy, pytest統合 | `pyproject.toml` |
| **Terraform検証** | fmt, validate, plan + checkov | `terraform/` |
| **セキュリティ** | pip-audit, gitleaks, checkov実装 | `.github/workflows/ci.yml` |
| **ヘルスチェック** | S3バケット検証スクリプト | `scripts/health_check.py` |
| **ロールバック** | 自動・手動ロールバック手順書 | `scripts/rollback.ps1`, `docs/DEPLOYMENT_HEALTH_AND_ROLLBACK.md` |
| **ブランチ保護** | 必須ステータスチェック自動適用 | `scripts/apply-branch-protection.ps1` |

---

## 週別進捗（計画vs実績）

### Week 1: CI の最小構成 ✅
**計画**
- Pythonのlint/format/test自動化
- PRで結果確認可能な状態

**実績**
- ruff (lint + format)
- mypy (型チェック)
- pytest (テスト + カバレッジ)
- すべて CI にて PR トリガーで実行確認

### Week 2: セキュリティ強化 ✅
**計画**
- pip-audit, gitleaks, tfsecを追加
- 失敗時にマージ不可ルール

**実績**
- pip-audit, gitleaks, checkov 実装
- ブランチ保護スクリプト作成
- 必須ステータスチェック設定完了

### Week 3: Terraform検証とデプロイ準備 ✅
**計画**
- fmt/validate/planをPRに組み込む
- dev環境への自動デプロイ作成

**実績**
- Terraform fmt/validate/plan を CI に統合
- CD で dev 環境への自動apply実装

### Week 4: 本番運用想定 ✅
**計画**
- stg/prodの手動承認フロー
- ロールバック手順と通知整備

**実績**
- Environment approval (stg/prod) 実装
- ロールバック手順書完成
- 通知（ログベース）出力準備

---

## 習得した技術・知識

### GitHub Actions
- ✅ ワークフロー設計（on:トリガー、jobs、steps）
- ✅ 環境変数・シークレット管理
- ✅ Environment approval の実装
- ✅ 条件付き実行（if: ステップ）
- ✅ 依存ジョブ（needs:）

### Python
- ✅ プロジェクト設定（pyproject.toml）
- ✅ Linting ツール比較（ruff vs black）
- ✅ 型チェック（mypy設定）
- ✅ テストフレームワーク（pytest）
- ✅ カバレッジ管理（pytest-cov）

### Terraform
- ✅ マルチ環境対応（dev/stg/prod 変数分離）
- ✅ リソース命名戦略（環境名を名前に含める）
- ✅ Provider設定（OIDC認証パス）
- ✅ セキュリティ検証ツール（checkov）

### AWS
- ✅ IAM role 構築（GitHub OIDC連携）
- ✅ S3 リソース管理
- ✅ 環境分離戦略

### Infrastructure as Code
- ✅ CI/CD設計原則（段階的デプロイ）
- ✅ ロールバック戦略
- ✅ ヘルスチェック設計
- ✅ 運用ドキュメント化

### DevOps/運用
- ✅ ブランチ戦略（feature/main ベース）
- ✅ デプロイ承認フロー
- ✅ 障害対応手順書作成
- ✅ 運用ログ記録テンプレート

---

## 実装時に工夫した点

### 1. 段階的実装
- Step 0～8 の順番に従い、検証可能な小さな単位で進捗
- 各ステップで「完了判定」を明確化

### 2. 環境衝突の回避
- S3 バケット名に環境名を含める: `cicd-learning-sample-app-{env}-{account}`
- Terraform 変数で環境ごとに分離

### 3. AWS 認証の安全化
- OIDC（Open ID Connect）による一時的な認証
- 長期アクセスキーを避ける

### 4. 失敗時対応の充実
- ヘルスチェック自動実施（Python脚本）
- ロールバック手順書（手動・自動シナリオ）
- 障害記録テンプレート

### 5. 自動化スクリプト
- PowerShell で GitHub API を呼び出し（ブランチ保護）
- Python で AWS SDK を使用（ヘルスチェック）
- DryRun オプションで安全性確保

---

## 課題と今後の拡張

### 現在の制限
- ❌ Slack/メール通知（Step 7）: GitHub の workflow status を Slack 連携可能だが、未実装
- ❌ シミュレーション演習（Step 8）: 障害シナリオの自動テスト未実装
- ⚠️ Terraform state: ローカル状態管理（S3 remote state は未設定）

### 推奨される次のステップ
1. **通知の統合**
   - Slack webhook による失敗通知
   - メール通知設定

2. **監視の強化**
   - CloudWatch アラーム連携
   - デプロイ後の メトリクス監視

3. **テストの拡充**
   - E2E テスト追加
   - 負荷テスト・カオスエンジニアリング

4. **IaC改善**
   - Terraform modules 化
   - backend S3 設定
   - state locking (DynamoDB)

5. **ドキュメント**
   - Architecture Decision Records (ADR)
   - 運用ガイドのビデオ化

---

## 習得難度の振り返り

| 領域 | 難度 | 理由 |
|------|------|------|
| GitHub Actions基本 | 🟢 低 | 公式ドキュメント充実 |
| Python品質ツール | 🟡 中 | 複数ツール組み合わせ、設定調整必要 |
| Terraform環境分離 | 🟡 中 | 変数管理、リソース命名規則の統一 |
| AWS認証(OIDC) | 🔴 高 | IAM role設定、信頼関係の複雑性 |
| 全体設計 | 🔴 高 | 段階的デプロイ、ロールバック戦略 |

---

## 学習時間見積もり

| Step | 見積もり | 実績 | 備考 |
|------|---------|------|------|
| 0 | 30分 | 20分 | ディレクトリ作成、メモ記載 |
| 1 | 60分 | 45分 | mypy 設定に時間 |
| 2 | 60分 | 50分 | terraform init + checkov 導入 |
| 3 | 120分 | 90分 | ワークフロー設計・実装 |
| 4 | 90分 | 60分 | PowerShell スクリプト作成 |
| 5 | 120分 | 100分 | CD ワークフロー、環境設定 |
| 6 | 90分 | 75分 | ヘルスチェック、ロールバック |
| **合計** | **570分** | **440分** | **7時間20分** |

---

## 成果物一覧

### コード
- Python: `app/calculator.py`, `tests/test_calculator.py`
- Terraform: `terraform/*.tf`
- Shell/PowerShell: `scripts/*.ps1`, `scripts/*.py`

### ワークフロー
- `.github/workflows/ci.yml` (4 jobs)
- `.github/workflows/cd.yml` (3 jobs)

### ドキュメント
- `README.md` (このプロジェクトの概要)
- `学習したい内容` (全体計画)
- `DEPLOYMENT_HEALTH_AND_ROLLBACK.md` (運用手順)
- `LEARNING_SUMMARY.md` (この文書)

### スクリプト/設定
- `pyproject.toml` (Python設定)
- `requirements-dev.txt` (依存パッケージ)

---

## 反省点と改善案

### 反省
1. **テンプレート構成**: ダミー S3 バケットではなく、実際のアプリケーション（Lambda, ECS など）を対象にすればより実践的だった
2. **通知未実装**: Slack 連携まで完成させたかった
3. **ドキュメント図解**: CI/CD フロー図をアスキーアートで表現したが、よりビジュアルに
4. **エラーハンドリング**: 各スクリプトの例外処理が簡易的

### 改善案
1. 実際のアプリケーションサンプル（Flask API など）を対象に
2. Slack notification アクション追加
3. draw.io で CI/CD 図を作成・埋め込み
4. 本番レベルのエラーハンドリング・ログ

---

## 今回のプロジェクトで活躍した技術スタック

```
┌─ GitHub
│   ├─ Actions (CI/CD)
│   ├─ Environments (Approval)
│   └─ Branch Protection Rules
├─ AWS
│   ├─ S3 (デプロイターゲット)
│   ├─ IAM (OIDC認証)
│   └─ CloudWatch (ログ)
├─ Terraform
│   ├─ AWS Provider
│   ├─ state management
│   └─ Multi-environment
└─ Python
    ├─ ruff (Lint)
    ├─ mypy (型チェック)
    └─ pytest (テスト)
```

---

## 参照リンク

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS GitHub OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_github.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ruff Documentation](https://docs.astral.sh/ruff/)

---

**作成日**: 2026-06-21
**プロジェクト**: 17-CICD-Pipeline
**学習期間**: 1日（実績）
