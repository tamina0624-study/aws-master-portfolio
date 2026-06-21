# ALB本体のリソース定義
resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.subnet_1_ids, var.subnet_2_ids]
  ip_address_type    = var.ip_address_type

  access_logs {
    enabled = var.alb_access_logs_enabled
    bucket  = var.alb_access_logs_bucket
    prefix  = var.alb_access_logs_prefix
  }

  connection_logs {
    enabled = var.alb_connection_logs_enabled
    bucket  = var.alb_connection_logs_bucket
    prefix  = var.alb_connection_logs_prefix
  }

  tags = var.tags
}
