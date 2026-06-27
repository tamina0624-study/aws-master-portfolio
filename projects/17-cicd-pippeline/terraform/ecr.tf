# ECR リポジトリ（コンテナイメージの保存先）
resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_136:KMS encryption is out of scope for this learning stack
  count = var.create_ecr ? 1 : 0

  name                 = "${var.project_name}-${var.app_name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.app_name}-ecr"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ライフサイクルポリシー（古いイメージを自動削除してコスト抑制）
resource "aws_ecr_lifecycle_policy" "app" {
  count      = var.create_ecr ? 1 : 0
  repository = aws_ecr_repository.app[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
