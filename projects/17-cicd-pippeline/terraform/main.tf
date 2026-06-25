data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.project_name}-${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  bucket_arn  = "arn:aws:s3:::${local.bucket_name}"
}

# バケットが存在しない場合のみ作成
resource "aws_s3_bucket" "app_bucket" {
  #checkov:skip=CKV_AWS_145:KMS encryption is out of scope for this learning stack
  #checkov:skip=CKV_AWS_18:Access logging destination bucket is not provisioned in this stack
  #checkov:skip=CKV_AWS_144:Cross-region replication is out of scope for this learning stack
  #checkov:skip=CKV2_AWS_62:Event notification target is not configured in this stack
  #checkov:skip=CKV2_AWS_61:Lifecycle configuration is intentionally omitted for demo data retention
  #checkov:skip=CKV_AWS_21:Versioning is configured via separate aws_s3_bucket_versioning resource
  #checkov:skip=CKV2_AWS_6:Public access block is configured via separate aws_s3_bucket_public_access_block resource
  count  = var.create_bucket ? 1 : 0
  bucket = local.bucket_name

  tags = {
    Name = "${var.app_name}-bucket1"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.app_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.app_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "app_bucket_ip_restriction" {
  count = var.create_bucket ? 1 : 0

  statement {
    sid    = "DenyRequestsOutsideAllowedSourceIp"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*"
    ]

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = [var.allowed_source_cidr]
    }

    condition {
      test     = "ArnNotLikeIfExists"
      variable = "aws:PrincipalArn"
      values = concat(
        var.ip_restriction_exempt_principal_arns,
        [data.aws_caller_identity.current.arn]
      )
    }
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  count  = var.create_bucket ? 1 : 0
  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.app_bucket_ip_restriction[0].json
}
