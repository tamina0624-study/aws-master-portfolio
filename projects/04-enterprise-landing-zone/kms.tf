# projects/04-enterprise-landing-zone/kms.tf

# 実行している自分のAWSアカウントIDを取得
data "aws_caller_identity" "current" {}

# CloudTrailなどのログ暗号化に使用するKMSキー
resource "aws_kms_key" "log_key" {
  description             = "KMS key for CloudTrail and Config logs"
  enable_key_rotation     = true # 【ポイント】1年ごとの自動ローテーションを有効化（セキュリティのベストプラクティス）
  deletion_window_in_days = 7

  # KMSのキーポリシー（誰がこの鍵を使えるか）
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        # CloudTrailがこの鍵を使ってログを暗号化できるようにする許可
        Sid    = "Allow CloudTrail to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "kms:GenerateDataKey*"
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-log-key"
  }
}

# KMSキーに分かりやすいエイリアス（別名）を付ける
resource "aws_kms_alias" "log_key_alias" {
  name          = "alias/${var.project_name}-log-key"
  target_key_id = aws_kms_key.log_key.key_id
}
