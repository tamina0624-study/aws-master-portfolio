# SSM Session Manager用 Interface VPC Endpoint
data "aws_region" "current" {}

resource "aws_security_group" "vpce_ssm" {
  name        = var.ssm_endpoint_security_group_name
  description = "Security group for SSM Session Manager VPC endpoints"
  vpc_id      = aws_vpc.analyze_research.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ssm_endpoint_security_group_name
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.analyze_research.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce_ssm.id]

  tags = {
    Name = var.ssm_vpc_endpoint_name
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.analyze_research.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce_ssm.id]

  tags = {
    Name = var.ssmmessages_vpc_endpoint_name
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.analyze_research.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce_ssm.id]

  tags = {
    Name = var.ec2messages_vpc_endpoint_name
  }
}
