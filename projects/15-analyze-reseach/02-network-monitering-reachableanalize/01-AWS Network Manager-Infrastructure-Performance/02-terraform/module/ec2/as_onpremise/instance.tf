# EC2インスタンスリソース定義
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                         = var.ami != "" ? var.ami : data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.vpc.onpremise_vpc.public_subnet_1_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = coalesce(var.iam.instance_profile_name, var.ec2_ssm_instance_profile_name)
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags      = var.tags_web
  user_data = var.user_data
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu の提供元)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "router" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.vpc.onpremise_vpc.public_subnet_1_id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = coalesce(var.iam.instance_profile_name, var.ec2_ssm_instance_profile_name)
  user_data_replace_on_change = true
  source_dest_check = false


  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags      = var.tags_router
  user_data = local.user_data_router
}

resource "aws_eip_association" "router" {
  allocation_id = var.vpc.onpremise_vpc.onprem_router_eip_allocation_id
  instance_id   = aws_instance.router.id
}
