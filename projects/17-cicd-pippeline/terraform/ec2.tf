data "aws_ami" "ec2_test" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_vpc" "ec2_test" {
  count  = 1

  cidr_block           = var.ec2_test_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-ec2-test-vpc"
  }
}

resource "aws_subnet" "ec2_test" {
  count  = 1

  vpc_id                  = aws_vpc.ec2_test[0].id
  cidr_block              = var.ec2_test_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-ec2-test-subnet"
  }
}

resource "aws_security_group" "ec2_test" {
  count  = 1

  name        = "${var.project_name}-${var.app_name}-${var.environment}-ec2-test-sg"
  description = "Security group for EC2 destroy test"
  vpc_id      = aws_vpc.ec2_test[0].id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ec2-test-sg"
  }
}

resource "aws_instance" "destroy_test" {
  count  = 1

  ami                         = data.aws_ami.ec2_test.id
  instance_type               = var.ec2_test_instance_type
  subnet_id                   = aws_subnet.ec2_test[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_test[0].id]
  associate_public_ip_address = false
  user_data                   = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    ls
    cat <<'MARKER' > /var/tmp/terraform-userdata.txt
    provisioned_by=terraform
    app_name=${var.app_name}
    environment=${var.environment}
    MARKER

    hostnamectl >> /var/tmp/terraform-userdata.txt
    date -Is >> /var/tmp/terraform-userdata.txt
  EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.app_name}-destroy-test"
  }
}
