# ALBリスナーのリソース定義
resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.this.arn
	port              = var.listener_port
	protocol          = var.listener_protocol
	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.web.arn
	}
}
