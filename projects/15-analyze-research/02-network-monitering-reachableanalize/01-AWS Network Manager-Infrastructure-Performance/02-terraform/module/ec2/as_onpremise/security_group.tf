# as_onpremise EC2用セキュリティグループ
# web サーバー兼 VPN ルーター向けのため IPsec ポートも許可する
resource "aws_security_group" "ec2" {
  name        = "analyze-research-ec2-sg-as-onpremise"
  description = "EC2 security group for as_onpremise web server and VPN router"
  vpc_id      = var.vpc.onpremise_vpc.vpc_id

  tags = {
    Name        = "analyze-research-ec2-sg-as-onpremise"
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

# HTTP インバウンド
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "192.168.1.1/32"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "HTTP from anywhere"
}

# HTTPS インバウンド
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "192.168.1.1/32"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS from anywhere"
}

# IKE (IPsec ネゴシエーション) - VPN ルーター用
resource "aws_vpc_security_group_ingress_rule" "ike" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "192.168.1.1/32"
  from_port         = 500
  to_port           = 500
  ip_protocol       = "udp"
  description       = "IKE for Site-to-Site VPN"
}

# IPsec NAT-T - VPN ルーター用
resource "aws_vpc_security_group_ingress_rule" "nat_t" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "192.168.1.1/32"
  from_port         = 4500
  to_port           = 4500
  ip_protocol       = "udp"
  description       = "IPsec NAT-T for Site-to-Site VPN"
}

# ICMP インバウンド（全許可）
resource "aws_vpc_security_group_ingress_rule" "icmp_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  description       = "All ICMP inbound"
}

# アウトバウンド（全許可）
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound traffic"
}
