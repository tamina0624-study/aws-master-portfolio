# ターゲットグループのリソース定義
resource "aws_lb_target_group" "web" {
	name        = var.tg_name
	port        = var.tg_port
	protocol    = var.tg_protocol
	vpc_id      = var.vpc_id
	target_type = var.tg_target_type
	health_check {
		path                = var.tg_health_check_path
		matcher             = var.tg_health_check_matcher
		interval            = var.tg_health_check_interval
		timeout             = var.tg_health_check_timeout
		healthy_threshold   = var.tg_health_check_healthy_threshold
		unhealthy_threshold = var.tg_health_check_unhealthy_threshold
	}
}
