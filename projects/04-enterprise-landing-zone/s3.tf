# projects/04-enterprise-landing-zone/s3.tf

# 1. ログ保存用のS3バケット本体を作成
resource "aws_s3_bucket" "cloudtrail_log_bucket" {
  # バケット名は世界中で重複できないため、アカウントIDを付けて一意にします
  bucket = "${var.project_name}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
}

# 2. パブリックアクセスの完全ブロック（重要）
# エンタープライズ環境では必須の設定です。予期せぬ情報漏洩を防ぎます。
resource "aws_s3_bucket_public_access_block" "cloudtrail_log_bucket_pab" {
  bucket                  = aws_s3_bucket.cloudtrail_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. S3バケットポリシー（誰がこのバケットに書き込めるか）
# CloudTrailというAWSサービス「だけ」が、このバケットにログを置けるように許可を出します。
resource "aws_s3_bucket_policy" "cloudtrail_log_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com" # 許可するサービス：CloudTrail
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_log_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject" # 書き込み（ファイル配置）を許可
        Resource = "${aws_s3_bucket.cloudtrail_log_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
