# AWSプロバイダーの設定
provider "aws" {
  region = var.aws_region
}

# ネットワークモジュールの呼び出し
module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  aws_region =var.aws_region
}



# セキュリティグループの作成
resource "aws_security_group" "portfolio_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = module.network.vpc_id

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

# コンピューティングモジュールの呼び出し
module "compute" {
  source       = "./modules/compute"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  subnet_id    = module.network.subnet_public_1_id
  aws_security_group_id = aws_security_group.portfolio_sg.id
}
