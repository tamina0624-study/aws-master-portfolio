
# ================================
# EC2 module main.tf（人間向け目次・導線）
# ================================
# このディレクトリはEC2集約moduleです。
#
# 【構成ファイル一覧】
#   - common/        : 共通IAM(SSMロール/インスタンスプロファイル)
#   - aws_vpc1/      : aws_vpc1向けEC2サブmodule
#   - aws_vpc2/      : aws_vpc2向けEC2サブmodule
#   - as_onpremise/  : as_onpremise向けEC2サブmodule
#   - variables.tf   : 集約module用変数定義
#   - outputs.tf     : 集約module用出力値定義
#
# 【注意事項】
# - module内はpure module方針
# - 環境依存・サービス固有値は受け取るだけ
# - 冗長でも明示的な記述を優先
#
# 【初見者向け導線】
# まずはこのmain.tfとREADME.mdを参照してください。

module "common_iam" {
  source                        = "./common"
  ec2_ssm_role_name             = var.ec2_ssm_role_name
  ec2_ssm_instance_profile_name = var.ec2_ssm_instance_profile_name
  tags                          = var.tags
}

module "ec2_aws_vpc1" {
  source                        = "./aws_vpc1"
  providers = {
    aws = aws.tokyo
  }
  vpc                           = var.vpc.aws_vpc1
  iam                           = module.common_iam
}

module "ec2_aws_vpc2" {
  source                        = "./aws_vpc2"
  providers = {
    aws = aws.tokyo
  }
  vpc                           = var.vpc.aws_vpc2
  iam                           = module.common_iam
}

module "ec2_as_onpremise" {
  source = "./as_onpremise"
  vpc    = var.vpc
  iam    = module.common_iam
}

# 別VPC間では SG 参照ができないため、CIDR で VPN/BGP 通信を許可
data "aws_vpc" "aws_vpc1" {
  provider = aws.tokyo
  id = var.vpc.aws_vpc1.vpc_id
}

data "aws_vpc" "onpremise_vpc" {
  id = var.vpc.onpremise_vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_from_onpremise_bgp" {
  provider          = aws.tokyo
  security_group_id = module.ec2_aws_vpc1.security_group_id
  cidr_ipv4         = data.aws_vpc.onpremise_vpc.cidr_block
  from_port         = 179
  to_port           = 179
  ip_protocol       = "tcp"
  description       = "BGP (TCP/179) from onpremise VPC CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_from_onpremise_ike" {
  provider          = aws.tokyo
  security_group_id = module.ec2_aws_vpc1.security_group_id
  cidr_ipv4         = data.aws_vpc.onpremise_vpc.cidr_block
  from_port         = 500
  to_port           = 500
  ip_protocol       = "udp"
  description       = "IKE (UDP/500) from onpremise VPC CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_from_onpremise_nat_t" {
  provider          = aws.tokyo
  security_group_id = module.ec2_aws_vpc1.security_group_id
  cidr_ipv4         = data.aws_vpc.onpremise_vpc.cidr_block
  from_port         = 4500
  to_port           = 4500
  ip_protocol       = "udp"
  description       = "IPsec NAT-T (UDP/4500) from onpremise VPC CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_from_onpremise_esp" {
  provider          = aws.tokyo
  security_group_id = module.ec2_aws_vpc1.security_group_id
  cidr_ipv4         = data.aws_vpc.onpremise_vpc.cidr_block
  ip_protocol       = "50"
  description       = "IPsec ESP (protocol 50) from onpremise VPC CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "vpc1_from_onpremise_icmp" {
  provider          = aws.tokyo
  security_group_id = module.ec2_aws_vpc1.security_group_id
  cidr_ipv4         = data.aws_vpc.onpremise_vpc.cidr_block
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  description       = "All ICMP from onpremise VPC CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "onpremise_from_vpc1_bgp" {
  security_group_id = module.ec2_as_onpremise.security_group_id
  cidr_ipv4         = data.aws_vpc.aws_vpc1.cidr_block
  from_port         = 179
  to_port           = 179
  ip_protocol       = "tcp"
  description       = "BGP (TCP/179) from VPC1 CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "onpremise_from_vpc1_ike" {
  security_group_id = module.ec2_as_onpremise.security_group_id
  cidr_ipv4         = data.aws_vpc.aws_vpc1.cidr_block
  from_port         = 500
  to_port           = 500
  ip_protocol       = "udp"
  description       = "IKE (UDP/500) from VPC1 CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "onpremise_from_vpc1_nat_t" {
  security_group_id = module.ec2_as_onpremise.security_group_id
  cidr_ipv4         = data.aws_vpc.aws_vpc1.cidr_block
  from_port         = 4500
  to_port           = 4500
  ip_protocol       = "udp"
  description       = "IPsec NAT-T (UDP/4500) from VPC1 CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "onpremise_from_vpc1_esp" {
  security_group_id = module.ec2_as_onpremise.security_group_id
  cidr_ipv4         = data.aws_vpc.aws_vpc1.cidr_block
  ip_protocol       = "50"
  description       = "IPsec ESP (protocol 50) from VPC1 CIDR"
}

resource "aws_vpc_security_group_ingress_rule" "onpremise_from_vpc1_icmp" {
  security_group_id = module.ec2_as_onpremise.security_group_id
  cidr_ipv4         = data.aws_vpc.aws_vpc1.cidr_block
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  description       = "All ICMP from VPC1 CIDR"
}
