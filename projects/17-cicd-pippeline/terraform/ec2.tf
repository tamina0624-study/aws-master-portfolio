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
  #checkov:skip=CKV2_AWS_11:VPC flow logs are configured in aws_flow_log.ec2_test_vpc; graph check can miss count-based links.
  #checkov:skip=CKV2_AWS_12:Default security group is managed by aws_default_security_group.ec2_test; graph check can miss count-based links.
  count = 1

  cidr_block           = var.ec2_test_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-ec2-test-vpc"
  }
}

data "aws_iam_policy_document" "ec2_test_flow_logs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_test_instance_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_test_flow_logs_kms" {
  #checkov:skip=CKV_AWS_111:KMS key policies require Resource "*" and controlled principals; this policy is scoped to account root and CloudWatch Logs service.
  #checkov:skip=CKV_AWS_356:For KMS key policies, Resource must be "*" by AWS design and cannot be narrowed to an ARN.
  #checkov:skip=CKV_AWS_109:Key administration statement for account root is intentionally broad to prevent key lockout in this learning stack.
  statement {
    sid    = "AllowRootAndAdmin"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::638892640336:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowVPCFlowLogsToUseKey"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "ec2_test_flow_logs_v4" {
  count = 1

  description         = "KMS key for EC2 test VPC flow logs v4"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.ec2_test_flow_logs_kms.json
}

resource "aws_cloudwatch_log_group" "ec2_test_flow_logs" {
  count = 1

  name              = "/aws/vpc/${var.project_name}-${var.app_name}-${var.environment}-ec2-test"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.ec2_test_flow_logs_v4[0].arn
}

resource "aws_iam_role" "ec2_test_flow_logs" {
  count = 1

  name               = "${var.project_name}-${var.app_name}-${var.environment}-flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_test_flow_logs_assume_role.json
}

resource "aws_iam_role_policy" "ec2_test_flow_logs" {
  count = 1

  name = "${var.project_name}-${var.app_name}-${var.environment}-flowlogs-policy"
  role = aws_iam_role.ec2_test_flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.ec2_test_flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "ec2_test_vpc" {
  count = 1

  iam_role_arn         = aws_iam_role.ec2_test_flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  log_group_name       = aws_cloudwatch_log_group.ec2_test_flow_logs[0].name
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.ec2_test[0].id

  depends_on = [aws_iam_role_policy.ec2_test_flow_logs]
}

resource "aws_subnet" "ec2_test" {
  count = 1

  vpc_id                  = aws_vpc.ec2_test[0].id
  cidr_block              = var.ec2_test_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-ec2-test-subnet"
  }
}

resource "aws_default_security_group" "ec2_test" {
  count = 1

  vpc_id = aws_vpc.ec2_test[0].id

  ingress = []
  egress  = []
}

resource "aws_security_group" "ec2_test" {
  #checkov:skip=CKV2_AWS_5:Security group is attached through aws_network_interface.ec2_test_primary in this file; graph check can miss count-based links.
  count = 1

  name        = "${var.project_name}-${var.app_name}-${var.environment}-ec2-test-sg"
  description = "Security group for EC2 destroy test"
  vpc_id      = aws_vpc.ec2_test[0].id

  egress {
    description = "Allow HTTP egress to internal network"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  tags = {
    Name = "${var.app_name}-ec2-test-sg"
  }
}

resource "aws_iam_role" "ec2_test_instance" {
  count = 1

  name               = "${var.project_name}-${var.app_name}-${var.environment}-ec2-test-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_test_instance_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_test_instance_ssm" {
  count = 1

  role       = aws_iam_role.ec2_test_instance[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_test_instance" {
  count = 1

  name = "${var.project_name}-${var.app_name}-${var.environment}-ec2-test-instance-profile"
  role = aws_iam_role.ec2_test_instance[0].name
}

resource "aws_network_interface" "ec2_test_primary" {
  count = 1

  subnet_id       = aws_subnet.ec2_test[0].id
  security_groups = [aws_security_group.ec2_test[0].id]
}

resource "aws_instance" "destroy_test" {
  #checkov:skip=CKV_AWS_126:Detailed monitoring is intentionally disabled for this short-lived cost-optimized test instance.
  #checkov:skip=CKV_AWS_135:t2.micro does not support EBS optimization in this learning stack.
  count = 1

  ami                  = data.aws_ami.ec2_test.id
  instance_type        = var.ec2_test_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_test_instance[0].name
  user_data            = <<-EOF
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

  root_block_device {
    encrypted = true
  }

  network_interface {
    network_interface_id = aws_network_interface.ec2_test_primary[0].id
    device_index         = 0
  }

  depends_on = [aws_iam_role_policy_attachment.ec2_test_instance_ssm]

  tags = {
    Name = "${var.app_name}-destroy-test"
  }
}
