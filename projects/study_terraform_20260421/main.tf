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
    Name = "${var.project_name}-public-1a"
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

# セキュリティグループの作成
resource "aws_security_group" "portfolio_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.portfolio_vpc.id

  # インバウンドルール（入ってくる通信）
  # SSH許可
# SSH許可（自分のIPのみ）
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # 取得したIPに /32 をつけて「特定の1つのIP」として指定
    cidr_blocks = ["${chomp(data.http.ifconfig.response_body)}/32"]
  }

  # HTTP許可
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.ifconfig.response_body)}/32"]
  }

  # アウトバウンドルール（出ていく通信）
  # 基本的にすべて許可するのが一般的
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # すべてのプロトコル
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# 最新のAmazon Linux 2023のAMI（イメージ） IDを自動取得
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# キーペアの登録
resource "aws_key_pair" "portfolio_key" {
  key_name   = "portfolio-key"
  public_key = file("./my-portfolio-key.pub") # 公開鍵を読み込む
}

# EC2インスタンスの作成
resource "aws_instance" "portfolio_web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro" # 無料枠対象

  # 作成したパブリックサブネットに配置
  subnet_id = aws_subnet.public_sub_1a.id

  associate_public_ip_address = true

  # 作成したセキュリティグループを適用
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]


  key_name = aws_key_pair.portfolio_key.key_name # 鍵を紐付け

  # --- ここから追加 ---
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Terraformで自動構築したWebサーバー</h1>" > /var/www/html/index.html
              EOF
  # --- ここまで追加 ---

  # サーバーに名前をつける
  tags = {
    Name = "${var.project_name}-web-server"
  }
}

# 実行後にサーバーのパブリックIPを表示させる設定
output "instance_public_ip" {
  value = aws_instance.portfolio_web.public_ip
}
