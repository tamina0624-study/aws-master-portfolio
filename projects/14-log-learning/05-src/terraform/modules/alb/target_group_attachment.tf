# ターゲットグループアタッチメントのリソース定義
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.target_instance_id
  port             = var.tg_port
}
