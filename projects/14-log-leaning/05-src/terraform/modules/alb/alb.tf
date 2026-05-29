# ALB本体のリソース定義
resource "aws_lb" "this" {
	name               = var.alb_name
	internal           = var.alb_internal
	load_balancer_type = "application"
	security_groups    = [var.alb_sg_id]
	subnets            = [var.subnet_1_ids, var.subnet_2_ids]
	ip_address_type    = var.ip_address_type
	tags               = var.tags
}
