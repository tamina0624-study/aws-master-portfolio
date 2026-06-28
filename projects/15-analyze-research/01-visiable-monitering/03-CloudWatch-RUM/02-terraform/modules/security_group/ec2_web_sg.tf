# EC2用セキュリティグループ
resource "aws_security_group" "ec2_web" {
  name        = var.ec2_web_sg_name
  description = var.ec2_web_sg_description
  vpc_id      = var.vpc_id

  # SSH (本番はIP制限推奨)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_web_ssh_cidr_blocks
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.ec2_web_http_cidr_blocks
  }

  # HTTP from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ec2_web_https_cidr_blocks
  }

  # HTTPS from specific security groups (e.g. SSM VPC endpoint SG)
  dynamic "ingress" {
    for_each = toset(var.ec2_web_https_source_security_group_ids)
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [ingress.value]
    }
  }

  # ICMP (疎通確認用)
  dynamic "ingress" {
    for_each = length(var.ec2_web_icmp_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = var.ec2_web_icmp_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ec2_web_sg_name
  }
}
