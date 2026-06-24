data "aws_caller_identity" "current" {}

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

data "aws_iam_policy_document" "app_bucket_ip_restriction" {
  statement {
    sid    = "DenyRequestsOutsideAllowedSourceIp"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.app_bucket.arn,
      "${aws_s3_bucket.app_bucket.arn}/*"
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
  bucket = aws_s3_bucket.app_bucket.id
  policy = data.aws_iam_policy_document.app_bucket_ip_restriction.json
}
