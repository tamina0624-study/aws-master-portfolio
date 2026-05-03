# オンプレミス（シミュレーション）側 VPC
resource "aws_vpc" "onprem_vpc" {
  cidr_block           = var.onprem_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "OnPrem-VPC" }
}

resource "aws_subnet" "onprem_public_subnet" {
  vpc_id                  = aws_vpc.onprem_vpc.id
  cidr_block              = cidrsubnet(var.onprem_vpc_cidr, 8, 0) # 172.16.0.0/24
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = { Name = "OnPrem-Public-Subnet" }
}

resource "aws_internet_gateway" "onprem_igw" {
  vpc_id = aws_vpc.onprem_vpc.id
  tags = { Name = "OnPrem-IGW" }
}

resource "aws_route_table" "onprem_public_rt" {
  vpc_id = aws_vpc.onprem_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.onprem_igw.id
  }
  tags = { Name = "OnPrem-Public-RT" }
}

resource "aws_route_table_association" "onprem_public_rta" {
  subnet_id      = aws_subnet.onprem_public_subnet.id
  route_table_id = aws_route_table.onprem_public_rt.id
}

# VPNルーター(EC2)用セキュリティグループ
resource "aws_security_group" "onprem_router_sg" {
  name        = "onprem-router-sg"
  description = "Security group for On-Premise VPN Router"
  vpc_id      = aws_vpc.onprem_vpc.id

  # IPsec (IKE) 用のポート
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # IPsec (NAT-T) 用のポート
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ESP (Encapsulating Security Payload) - protocol 50
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "50"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Pingやテスト通信をVPC内外から許可
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # sshをVPC内外から許可
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["164.70.177.198/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "OnPrem-Router-SG" }
}
