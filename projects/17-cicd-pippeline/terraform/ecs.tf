# ECS Fargate リソース（コンテナアプリのデプロイ基盤）
# create_ecs = true にすることで有効化

# ─────────────────────────────────────────────
# ECS クラスタ
# ─────────────────────────────────────────────
resource "aws_ecs_cluster" "app" {
  count = var.create_ecs ? 1 : 0
  name  = "${var.project_name}-${var.app_name}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.app_name}-ecs-cluster"
  }
}

# ─────────────────────────────────────────────
# IAM: タスク実行ロール（ECR pull / CloudWatch ログ書き込み）
# ─────────────────────────────────────────────
data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  count = var.create_ecs ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  count              = var.create_ecs ? 1 : 0
  name               = "${var.project_name}-${var.app_name}-${var.environment}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count      = var.create_ecs ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ─────────────────────────────────────────────
# CloudWatch Logs グループ（コンテナログ出力先）
# ─────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "ecs_app" {
  count = var.create_ecs ? 1 : 0

  name              = "/ecs/${var.project_name}-${var.app_name}-${var.environment}"
  retention_in_days = 30
}

# ─────────────────────────────────────────────
# ECS タスク定義
# ─────────────────────────────────────────────
resource "aws_ecs_task_definition" "app" {
  count = var.create_ecs ? 1 : 0

  family                   = "${var.project_name}-${var.app_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution[0].arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.create_ecr ? "${aws_ecr_repository.app[0].repository_url}:latest" : "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.ecs_container_port
          protocol      = "tcp"
        }
      ]

      readonlyRootFilesystem = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.app_name}-${var.environment}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-task-def"
  }
}

# ─────────────────────────────────────────────
# セキュリティグループ（ECS タスク用：コンテナポートのみ許可）
# ─────────────────────────────────────────────
resource "aws_security_group" "ecs_tasks" {
  #checkov:skip=CKV2_AWS_5:Security group is attached to ECS tasks via aws_ecs_service
  count = var.create_ecs ? 1 : 0

  name        = "${var.project_name}-${var.app_name}-${var.environment}-ecs-sg"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = var.ecs_vpc_id

  ingress {
    description = "Allow container port"
    from_port   = var.ecs_container_port
    to_port     = var.ecs_container_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    description = "Allow all outbound (ECR pull, CloudWatch)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs-sg"
  }
}

# ─────────────────────────────────────────────
# ECS サービス（Fargate）
# ─────────────────────────────────────────────
resource "aws_ecs_service" "app" {
  count = var.create_ecs ? 1 : 0

  name            = "${var.project_name}-${var.app_name}-${var.environment}"
  cluster         = aws_ecs_cluster.app[0].id
  task_definition = aws_ecs_task_definition.app[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks[0].id]
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    # CD ワークフローがタスク定義を更新するため、Terraform 管理から除外
    ignore_changes = [task_definition]
  }

  tags = {
    Name = "${var.app_name}-ecs-service"
  }
}
