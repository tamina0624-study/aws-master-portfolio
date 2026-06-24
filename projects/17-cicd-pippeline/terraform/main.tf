data "aws_caller_identity" "current" {}

# 既存のバケットを参照（存在しない場合は無視）
data "aws_s3_bucket" "existing_bucket" {
  bucket = "${var.project_name}-${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  count  = 0 # Initially, we don't look for existing bucket
}

# バケットが存在しない場合のみ作成
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.app_name}-bucket"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}
