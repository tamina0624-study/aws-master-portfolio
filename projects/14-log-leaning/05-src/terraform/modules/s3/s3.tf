# 既存S3バケットを参照（作成しない）
locals {
  bucket_name = var.bucket_name
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = local.bucket_name

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_sse" {
  bucket = local.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = "arn:aws:s3:::${local.bucket_name}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
}
