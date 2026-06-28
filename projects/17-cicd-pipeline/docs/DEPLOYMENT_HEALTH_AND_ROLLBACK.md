# デプロイ後検証とロールバック手順

## 1. デプロイ後ヘルスチェック

### 自動ヘルスチェック（GitHub Actions）
CD ワークフロー内で各デプロイ直後に以下をチェック：
- S3 バケット存在確認
- バージョニング有効化確認
- タグ付け確認

実行：GitHub Actions の `health-check` ステップで自動実施

### ローカル実行
```bash
# 環境変数設定
$env:S3_BUCKET_NAME = "cicd-learning-sample-app-dev-638892640336"
$env:ENVIRONMENT = "dev"

# Python スクリプト実行
python scripts/health_check.py
```

**ヘルスチェック項目**
- [x] バケット存在確認
- [x] バージョニング状態
- [x] タグ付け状態

**失敗時の対応**
- ログに詳細を確認
- AWS コンソールから手動確認
- Step 2 のロールバック手順へ進む

---

## 2. ロールバック手順

### 自動ロールバック（失敗時）
CD ワークフローでヘルスチェック失敗時：
- 自動で Step 6 ロールバックジョブをトリガー
- Terraform state backup から復旧
- 前バージョンへ自動 apply

### 手動ロールバック

#### 前提
- ローカル環境の terraform が初期化済み
- AWS 認証済み
- S3 remote state へのアクセス権限がある場合はロックを確認

#### 実行手順

**Step 1: 現在の状態を確認**
```powershell
cd projects/17-cicd-pipeline/terraform
terraform state list
terraform state show aws_s3_bucket.app_bucket
```

**Step 2: ロールバック実行**
```powershell
# Dry run で影響を確認
./scripts/rollback.ps1 -Environment dev -DryRun

# 実際に実行（確認プロンプト有）
./scripts/rollback.ps1 -Environment dev
```

**Step 3: ロールバック後検証**
```powershell
terraform plan -no-color
# plan に想定外の破壊操作が含まれていないか確認
```

---

## 3. 失敗シナリオ別対応

### シナリオ 1: デプロイ直後ヘルスチェック失敗
1. ワークフロー失敗ログから原因特定
2. AWS コンソールで手動確認
3. ロールバック実行
4. 原因を修正して再 push

### シナリオ 2: 本番環境で予期しない動作
1. 即座に CloudWatch ログ確認
2. 影響範囲を評価
3. ロールバック実施
4. root cause analysis を実施後、修正版をリリース

### シナリオ 3: Terraform state 破損
1. `.terraform` フォルダを削除
2. `terraform init` を再実行
3. remote state から同期
4. `terraform plan` で差分を確認
5. 必要に応じてロールバック

---

## 4. 運用時チェックリスト

デプロイ前
- [ ] PR でコード レビュー完了
- [ ] CI パイプライン全通過
- [ ] `terraform plan` 差分を承認者が確認

デプロイ中
- [ ] CD ワークフロー実行ログを監視
- [ ] 段階的デプロイ（dev → stg → prod）進行状況確認

デプロイ後
- [ ] ヘルスチェック PASS 確認
- [ ] AWS コンソールで手動確認
- [ ] ログで異常がないか確認

トラブル時
- [ ] ロールバック手順を実施
- [ ] 復旧完了後、root cause を記録
- [ ] 改善案をチケット化

---

## 5. 記録方法

デプロイ失敗時は以下を記録：
- 日時
- 環境（dev/stg/prod）
- コミット ID
- 失敗原因
- ロールバック実施日時
- 対応状況
- 再リリース予定日

**記録テンプレート**
```
日時: 2026-06-21 14:30 UTC
環境: dev
コミット: abc1234
失敗原因: S3 バケット命名衝突
ロールバック: 実施済み（14:35）
対応: バケット命名ルール修正
再リリース: 2026-06-21 15:00
```

最終CDトリガー実行日: 2026-06-24
