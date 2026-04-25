# projects/04-enterprise-landing-zone/cloudtrail.tf

resource "aws_cloudtrail" "main_trail" {
  name                          = "${var.project_name}-main-trail"
  
  # ログの保存先として、先ほど作ったS3バケットを指定
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log_bucket.id
  
  # ログの暗号化に、最初に作ったKMSキーを指定
  kms_key_id                    = aws_kms_key.log_key.arn
  
  # 【重要】すべてのリージョン（東京や米国など）の操作を記録する
  is_multi_region_trail         = true
  
  # IAMなどの「特定のリージョンに縛られないサービス」の操作も記録する
  include_global_service_events = true
  
  # 【重要】保存したログが後から改ざんされていないかを証明する機能を有効化
  enable_log_file_validation    = true

  # S3やKMSの「受け入れ準備（ポリシー設定）」が完了するまで作成を待つ
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_log_bucket_policy,
    aws_kms_key.log_key
  ]
}
