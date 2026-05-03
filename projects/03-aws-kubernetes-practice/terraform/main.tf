# projects/03-aws-kubernetes-practice/terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# 既存のVPCモジュールなどを呼び出す想定（適宜パスは調整してください）
module "basic_infrastructure" {
  source = "../../01-basic-infrastructure"
}

# K8s練習用EC2の設定
resource "aws_instance" "k8s_practice" {
  ami           = module.basic_infrastructure.ami_id
  instance_type = "t3.small" # K8sを動かすため少し余裕を持たせます（無料枠外になる場合はt2.microでも可）

  subnet_id              = module.basic_infrastructure.subnet_id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = "portfolio-key" # 作成済みのキーペア名

  # インスタンス起動時にK3sを自動インストール
  user_data = <<-EOF
              #!/bin/bash
              curl -sfL https://get.k3s.io | sh -
              # 一般ユーザー(ec2-user)でkubectlを使えるように権限設定
              mkdir -p /home/ec2-user/.kube
              cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
              chown ec2-user:ec2-user /home/ec2-user/.kube/config
              EOF

  tags = {
    Name = "k8s-practice-server"
  }
}

# K8s用のセキュリティグループ
resource "aws_security_group" "k8s_sg" {
  name   = "k8s-practice-sg"
  vpc_id = module.basic_infrastructure.vpc_id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(module.basic_infrastructure.my_ip)}/32"] # variables.tfで定義した自分のIP
  }

  # K8s API Server (kubectlでの接続用)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(module.basic_infrastructure.my_ip)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
