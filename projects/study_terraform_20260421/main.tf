# AWSプロバイダーの設定
provider "aws" {
  region = var.aws_region
}

# VPCの作成
resource "aws_vpc" "portfolio_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}


# 1. サブネットの作成（Public）
resource "aws_subnet" "public_sub_1a" {
  vpc_id            = aws_vpc.portfolio_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "portfolio-public-1a"
  }
}

# 2. インターネットゲートウェイの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.portfolio_vpc.id

  tags = {
    Name = "portfolio-igw"
  }
}

# 3. ルートテーブルの作成
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.portfolio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "portfolio-public-rt"
  }
}

# 4. サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_sub_1a.id
  route_table_id = aws_route_table.public_rt.id
}