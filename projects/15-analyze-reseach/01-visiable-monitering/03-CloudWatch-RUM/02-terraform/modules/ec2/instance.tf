# EC2インスタンスリソース定義
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = coalesce(var.iam_instance_profile, aws_iam_instance_profile.ec2_ssm.name)
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags      = var.tags
  user_data = var.user_data
}
