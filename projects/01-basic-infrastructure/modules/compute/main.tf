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
  subnet_id = var.subnet_id

  associate_public_ip_address = true

  # 作成したセキュリティグループを適用
  vpc_security_group_ids = [var.aws_security_group_id]


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
