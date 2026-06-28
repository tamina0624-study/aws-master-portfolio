resource "aws_security_group" "lambda" {
  name        = "analyze-research-lambda-sg"
  description = "Security group for Lambda to access RDS"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "analyze-research-lambda-sg"
  }
}

data "aws_secretsmanager_secret_version" "rds_master" {
  secret_id = module.rds.master_user_secret_arn
}

locals {
  rds_master_secret = jsondecode(data.aws_secretsmanager_secret_version.rds_master.secret_string)
}
