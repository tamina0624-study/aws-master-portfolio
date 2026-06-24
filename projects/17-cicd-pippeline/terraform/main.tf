data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.project_name}-${var.app_name}-${var.environment}-${data.aws_caller_identity.current.account_id}"
  bucket_arn  = "arn:aws:s3:::${local.bucket_name}"
}

# バケットが存在しない場合のみ作成
resource "aws_s3_bucket" "app_bucket" {
  count  = var.create_bucket ? 1 : 0
  bucket = local.bucket_name

  tags = {
    Name = "${var.app_name}-bucket"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "app_bucket_pab" {
  bucket = local.bucket_name

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = local.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_tagging" "app_bucket_tags" {
  bucket = local.bucket_name

  tag_set = {
    Name        = "${var.app_name}-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

# バケットポリシーは作成後に手動で適用するため、一時的にコメントアウト
# data "aws_iam_policy_document" "app_bucket_ip_restriction" {
#   statement {
#     sid    = "DenyRequestsOutsideAllowedSourceIp"
#     effect = "Deny"
#
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }
#
#     actions = ["s3:*"]
#
#     resources = [
#       local.bucket_arn,
#       "${local.bucket_arn}/*"
#     ]
#
#     condition {
#       test     = "NotIpAddress"
#       variable = "aws:SourceIp"
#       values   = [var.allowed_source_cidr]
#     }
#
#     dynamic "condition" {
#       for_each = length(var.ip_restriction_exempt_principal_arns) > 0 ? [1] : []
#
#       content {
#         test     = "ArnNotLikeIfExists"
#         variable = "aws:PrincipalArn"
#         values   = var.ip_restriction_exempt_principal_arns
#       }
#     }
#   }
# }
#
# resource "aws_s3_bucket_policy" "app_bucket_policy" {
#   bucket = local.bucket_name
#   policy = data.aws_iam_policy_document.app_bucket_ip_restriction.json
# }
