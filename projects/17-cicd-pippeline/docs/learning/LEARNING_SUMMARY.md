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

### 🔍 各ツールで検出できる不具合（具体例）

#### 1. Python品質チェック（ruff / mypy / pytest）
- **ruff**
   - 未使用import、未使用変数、到達不能コード
   - 例外処理や比較式などの危険な書き方
   - フォーマット崩れやスタイル不整合
- **mypy**
   - 型不一致（例: `str` と `int` の混在）
   - `None` を考慮しない参照ミス
   - 関数シグネチャと実装の不整合
- **pytest**
   - ロジック不具合（期待値と実装結果のずれ）
   - 回帰不具合（既存機能の破壊）
   - 境界値処理ミス（空値、0件、上限値）

#### 2. Terraform検証（fmt / validate / plan / checkov）
- **fmt**
   - 直接的なバグ検出ではないが、記法ゆれを統一してレビュー漏れを減らす
- **validate**
   - Terraform構文エラー
   - 不正な引数、型ミス、参照ミス
- **plan**
   - 想定外差分（不要な削除・過剰な作成・予期しない変更）
   - 変数値ミスによる誤構成
   - 実検証例（2026-06-25）
     - aws_s3_bucket_policy.app_bucket_policy[0] の新規作成差分を検知
     - aws_s3_bucket.app_bucket[0] の tags_all 更新差分（ManagedBy タグ追加）を検知
     - リソースアドレス変更差分（app_bucket -> app_bucket[0] など）を検知
- **checkov**
   - セキュリティ設定不備（公開設定、暗号化不足、監査ログ不足など）
   - IaCベストプラクティス違反

#### 3. セキュリティ（pip-audit / gitleaks / checkov）
- **pip-audit**
   - 既知脆弱性を含む依存パッケージ
   - 修正可能なアップデート候補
- **gitleaks***
   - APIキー、トークン、秘密鍵などの機密情報混入
   - コミット履歴や差分内のシークレット漏えい
- **checkov**
   - Terraform定義上のクラウドセキュリティホール

#### 4. ヘルスチェック（S3バケット検証スクリプト）
- デプロイ後の実体不整合（デプロイ成功表示でも実体が不正）
- バケット未作成、権限不足、リージョン不一致
- 想定した環境名・命名規則との不一致

#### 5. ロールバック（自動・手動手順）
- 検出ツールというより復旧手段だが、運用不備を顕在化できる
- 手順漏れ、依存関係ミス、戻し先指定ミスの発見に有効
- 定期演習により障害時の復旧失敗リスクを低減

#### 6. ブランチ保護（必須ステータスチェック）
- 不具合を直接検出する機能ではないが、main流入前の防波堤として有効
- CI失敗・未レビュー状態のマージを防止
- 品質未達コードの本番流入リスクを継続的に抑制

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

### 6. 重要インフラの保護設計
- 本番環境デプロイは必ず手動承認フローを通す（自動 apply 禁止）
- S3・DB などの重要リソースは `lifecycle { prevent_destroy = true }` で誤削除を防ぐ
- Terraform state と実リソースの整合性を維持し、既存リソースを誤って再作成しない設計を徹底

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

6. **サーバーイメージ CI/CD**
   - Docker イメージのビルド・プッシュ・スキャンをパイプラインに組み込む
   - ECR への自動プッシュと ECS/EKS 連携

---

## 実装時の躓きと対策（CD不具合対応 2026-06-24〜2026-06-25）

実際のCDパイプライン構築中に発生した問題と再発防止策の記録。

| # | 問題 | 原因 | 対策 | 再発防止 |
|---|------|------|------|----------|
| 1 | CDがスキップされる | `AWS_ROLE_ARN` などの Repository Variables 未設定 | Variables と Environment を設定 | 新規リポジトリの初期設定チェックリストに追加 |
| 2 | OIDC認証失敗（AssumeRoleWithWebIdentity） | IAMロール信頼ポリシーの `sub` 条件が厳しすぎ | `StringLike` + リポジトリスコープの条件に調整 | push/PR/workflow_dispatch の3系統で事前疎通テスト |
| 3 | cd.yml YAML構文エラー | BOM付きUTF-8・インデント崩れ | BOMなしUTF-8で保存、インデントを全面修正 | push前にローカルで YAML lint 相当チェックを実施 |
| 4 | ruff I001エラー（import並び順） | stdlib と third-party import の区切りが規約不一致 | import 順を修正（空行で区切る） | ローカルで `ruff check` / `ruff format --check` を必須化 |
| 5 | mypy boto3型情報エラー | deploy スクリプトまで厳格型チェック対象になっていた | `pyproject.toml` で mypy 対象範囲を調整 | アプリ本体と運用スクリプトで品質ゲートを分離 |
| 6 | Terraform init 失敗（Duplicate data resource） | `main.tf` 内で同一 `data` ブロックが重複定義 | 重複定義を削除、未使用 data source も整理 | PR時に `terraform validate` を必須化 |
| 7 | S3作成 409エラー（BucketAlreadyOwnedByYou） | state と実リソースの不整合 | `terraform import` + `-var="environment=..."` 明示で再apply | 既存リソースがある環境は import/再実行戦略をワークフローに組み込み |
| 8 | ヘルスチェック 403（AccessDenied） | Actions 実行ロールの S3 権限不足 | List/Get/Tagging などの必要 API をロールポリシーに追加 | ヘルスチェック実装前に必要 API 一覧を権限設計へ反映 |
| 9 | aws_s3_bucket_tagging 非対応エラー | 利用中 provider バージョンと該当リソースが非対応 | 該当リソースを外し、タグ処理を CLI 側へ退避 | provider バージョンと利用リソースの対応表を事前確認 |

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
