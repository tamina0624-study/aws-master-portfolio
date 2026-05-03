# projects/04-enterprise-landing-zone/iam_boundary.tf

# 1. 開発者向けの「越えてはいけない境界線（Permissions Boundary）」の定義
resource "aws_iam_policy" "developer_boundary" {
  name        = "${var.project_name}-developer-boundary"
  description = "Prevent deletion of core security baseline resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # ① 基本はすべての操作を許可（実際の権限は付与されたポリシーに依存する）
        Sid      = "AllowAll"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        # ② 【重要】ただし、監査・セキュリティの土台（CloudTrail, S3, KMS）を破壊・停止する操作は「絶対拒否（Deny）」
        Sid      = "DenySecurityBaselineTampering"
        Effect   = "Deny"
        Action   = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",       # ログ取得の停止を禁止
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketPublicAccessBlock", # S3をパブリック公開に戻すことを禁止
          "kms:ScheduleKeyDeletion",       # 暗号化キーの削除を禁止
          "kms:DisableKey"
        ]
        # 先ほど作成した3つのリソースを守る
        Resource = [
          aws_cloudtrail.main_trail.arn,
          aws_s3_bucket.cloudtrail_log_bucket.arn,
          aws_kms_key.log_key.arn
        ]
      },
      {
        # ③ 【重要】この「境界線ルール」自体を自分で解除・変更して逃げ出すことを禁止
        Sid      = "DenyBoundaryModification"
        Effect   = "Deny"
        Action   = [
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeleteUserPermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary"
        ]
        Resource = "*"
      }
    ]
  })
}

# 2. ガードレール付きの「開発者用IAMロール」を作成
resource "aws_iam_role" "developer_role" {
  name = "${var.project_name}-developer-role"

  # （今回はテスト用として、EC2がこのロールを引き受けられるように設定）
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  # 【見せ場】このロールには、必ず上記の「境界線（Boundary）」がセットされる
  permissions_boundary = aws_iam_policy.developer_boundary.arn
}

# 3. 開発者ロールに「開発者の権限（PowerUserAccess）」を付与する
resource "aws_iam_role_policy_attachment" "developer_admin" {
  role       = aws_iam_role.developer_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
