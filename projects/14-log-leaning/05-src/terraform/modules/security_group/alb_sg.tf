# ALB用セキュリティグループ
resource "aws_security_group" "alb" {
	name        = var.alb_sg_name
	description = var.alb_sg_description
	vpc_id      = var.vpc_id

	# HTTP
	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = var.alb_http_cidr_blocks
	}

	# HTTPS
	ingress {
		from_port   = 443
		to_port     = 443
		protocol    = "tcp"
		cidr_blocks = var.alb_https_cidr_blocks
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = var.alb_sg_name
	}
}
