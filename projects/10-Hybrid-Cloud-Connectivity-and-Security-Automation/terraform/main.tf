# --- WAFv2 IP Set: allow-ipset ---
resource "aws_wafv2_ip_set" "allow_ipset" {
	name               = "allow-ipset"
	scope              = "REGIONAL"
	ip_address_version = "IPV4"
	addresses = [
		# AWS側サブネット
		"10.0.1.0/24",
		"10.0.2.0/24",
		"10.0.11.0/24",
		"10.0.12.0/24",
		# オンプレ側サブネット
		"10.1.1.0/24",
		"10.1.2.0/24"
		# 必要に応じて個別IPも追加可能
	]
	tags = merge(var.tags, { Name = "allow-ipset" })
}

# --- WAFv2 IP Set: deny-ipset（初期は空） ---
resource "aws_wafv2_ip_set" "deny_ipset" {
	name               = "deny-ipset"
	scope              = "REGIONAL"
	ip_address_version = "IPV4"
	addresses          = []
	tags = merge(var.tags, { Name = "deny-ipset" })
}
# --- GuardDuty Detector ---
resource "aws_guardduty_detector" "main" {
	enable = true
}

# --- Lambda（攻撃元IPブロック） ---
resource "aws_lambda_function" "block_attacker_ip_port" {
	function_name = "hcsa-lambda-block_attacker_ip_port"
	role          = aws_iam_role.lambda_block_attacker.arn
	handler       = "lambda_function.lambda_handler"
	runtime       = "python3.8"
	timeout       = 3
	memory_size   = 128
	filename      = var.lambda_block_attacker_zip
	source_code_hash = filebase64sha256(var.lambda_block_attacker_zip)
	tags          = var.tags
}

# --- EventBridgeルール（GuardDuty Finding → Lambda） ---
resource "aws_cloudwatch_event_rule" "guardduty_finding" {
	name        = "hcsa-eventbridge-guardduty-finding-to-lambda"
	description = "GuardDutyのFindingをLambdaへ転送"
	event_pattern = <<PATTERN
{
	"source": ["aws.guardduty"],
	"detail-type": ["GuardDuty Finding"],
	"detail": {
		"type": [
			"UnauthorizedAccess*",
			"Recon*",
			"Trojan*",
			"Backdoor*",
			"CryptoCurrency*",
			"Impact*",
			"Persistence*",
			"PenTest*",
			"Behavior*"
		]
	}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "guardduty_to_lambda" {
	rule      = aws_cloudwatch_event_rule.guardduty_finding.name
	arn       = aws_lambda_function.block_attacker_ip_port.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
	statement_id  = "AllowExecutionFromEventBridge"
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.block_attacker_ip_port.function_name
	principal     = "events.amazonaws.com"
	source_arn    = aws_cloudwatch_event_rule.guardduty_finding.arn
}
# --- RDS用サブネットグループ ---
resource "aws_db_subnet_group" "prod_hcsa_rds" {
	name       = "prod-hcsa-rds-subnet-group"
	subnet_ids = [module.aws_vpc.private_subnet_ids[0]]
	tags       = merge(var.tags, { Name = "prod-hcsa-rds-subnet-group" })
}

# --- RDSインスタンス ---
resource "aws_db_instance" "prod_hcsa_rds" {
	identifier              = "prod-hcsa-vpc-rds"
	engine                  = "mysql"
	instance_class          = "db.t4g.micro"
	allocated_storage       = 20
	storage_type            = "gp2"
	db_subnet_group_name    = aws_db_subnet_group.prod_hcsa_rds.name
	vpc_security_group_ids  = [aws_security_group.prod_hcsa_vpc_rds_sg.id]
	username                = var.rds_master_username
	password                = var.rds_master_password
	db_name                 = "hcsa_db"
	multi_az                = false
	availability_zone       = "us-east-2a"
	publicly_accessible     = false
	skip_final_snapshot     = true
	deletion_protection     = false
	tags                    = merge(var.tags, { Name = "prod-hcsa-vpc-rds" })
	iam_database_authentication_enabled = true
}
# --- AWS側VPC: パブリックサブネット用ルートテーブル ---
resource "aws_route_table" "aws_public" {
	vpc_id = module.aws_vpc.vpc_id
	tags   = merge(var.tags, { Name = "prod-hcsa-public-rtb" })
}

resource "aws_route_table_association" "aws_public" {
	count          = length(module.aws_vpc.public_subnet_ids)
	subnet_id      = module.aws_vpc.public_subnet_ids[count.index]
	route_table_id = aws_route_table.aws_public.id
}

# --- AWS側VPC: プライベートサブネット用ルートテーブル ---
resource "aws_route_table" "aws_private" {
	vpc_id = module.aws_vpc.vpc_id
	tags   = merge(var.tags, { Name = "prod-hcsa-private-rtb" })
}

resource "aws_route_table_association" "aws_private" {
	count          = length(module.aws_vpc.private_subnet_ids)
	subnet_id      = module.aws_vpc.private_subnet_ids[count.index]
	route_table_id = aws_route_table.aws_private.id
}

# --- オンプレVPC用ルートテーブル ---
resource "aws_route_table" "onprem" {
	vpc_id = module.onprem_vpc.vpc_id
	tags   = merge(var.tags, { Name = "onprem-hcsa-rtb" })
}

resource "aws_route_table_association" "onprem_public" {
	count          = length(module.onprem_vpc.public_subnet_ids)
	subnet_id      = module.onprem_vpc.public_subnet_ids[count.index]
	route_table_id = aws_route_table.onprem.id
}

resource "aws_route_table_association" "onprem_private" {
	count          = length(module.onprem_vpc.private_subnet_ids)
	subnet_id      = module.onprem_vpc.private_subnet_ids[count.index]
	route_table_id = aws_route_table.onprem.id
}

# --- VPN経路（AWSプライベート→オンプレVPC） ---
resource "aws_vpn_gateway_route_propagation" "vgw_route" {
  vpn_gateway_id = aws_vpn_gateway.prod_hcsa_vgw.id
  route_table_id = aws_route_table.aws_private.id
}


# 仮想プライベートゲートウェイ（VGW）
resource "aws_vpn_gateway" "prod_hcsa_vgw" {
	vpc_id = module.aws_vpc.vpc_id
	tags   = merge(var.tags, { Name = "prod-hcsa-vgw" })
}

# カスタマーゲートウェイ（オンプレ想定）
resource "aws_customer_gateway" "onprem" {
	bgp_asn    = 65000
	ip_address = var.onprem_gateway_ip # 疑似オンプレ側のグローバルIPを指定
	type       = "ipsec.1"
	tags       = merge(var.tags, { Name = "onprem-cgw" })
}

# VPN接続
resource "aws_vpn_connection" "onprem" {
	vpn_gateway_id      = aws_vpn_gateway.prod_hcsa_vgw.id
	customer_gateway_id = aws_customer_gateway.onprem.id
	type                = "ipsec.1"
	static_routes_only  = true
	tags                = merge(var.tags, { Name = "onprem-vpn-connection" })
}

# VPNルート（AWS側VPCルートテーブルに追加する場合の例）
resource "aws_vpn_connection_route" "onprem" {
	vpn_connection_id = aws_vpn_connection.onprem.id
	destination_cidr_block = var.onprem_vpc_cidr
}
resource "aws_iam_role" "lambda_block_attacker" {
	name = "hcsa-lambda-block_attacker_ip_port"
	assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
	tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_block_attacker_basic" {
	role       = aws_iam_role.lambda_block_attacker.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_block_attacker_custom" {
	name   = "hcsa-lambda-block_attacker_ip_port-custom"
	policy = data.aws_iam_policy_document.lambda_block_attacker_custom.json
}

resource "aws_iam_role_policy_attachment" "lambda_block_attacker_custom" {
	role      = aws_iam_role.lambda_block_attacker.name
	policy_arn = aws_iam_policy.lambda_block_attacker_custom.arn
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["lambda.amazonaws.com"]
		}
	}
}

data "aws_iam_policy_document" "lambda_block_attacker_custom" {
	statement {
		actions = [
			"events:PutEvents",
			"events:DescribeRule",
			"events:EnableRule",
			"ec2:AuthorizeSecurityGroupIngress",
			"ec2:RevokeSecurityGroupIngress",
			"ec2:AuthorizeSecurityGroupEgress",
			"ec2:RevokeSecurityGroupEgress",
			"ec2:CreateNetworkAclEntry",
			"ec2:DeleteNetworkAclEntry",
			"ec2:ReplaceNetworkAclEntry"
		]
		resources = ["*"]
	}
}
resource "aws_iam_role" "appserver" {
	name = "hcsa-ec2-appserver-role"
	assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
	tags = var.tags
}

resource "aws_iam_role_policy_attachment" "appserver_ssm" {
	role       = aws_iam_role.appserver.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "appserver_cloudwatch" {
	role       = aws_iam_role.appserver.name
	policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
resource "aws_iam_role_policy_attachment" "appserver_rds" {
	role       = aws_iam_role.appserver.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role" "routerpc" {
	name = "hcsa-ec2-routerpc-role"
	assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
	tags = var.tags
}
resource "aws_iam_role_policy_attachment" "routerpc_ssm" {
	role       = aws_iam_role.routerpc.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "routerpc_cloudwatch" {
	role       = aws_iam_role.routerpc.name
	policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "userpc" {
	name = "hcsa-ec2-userpc-role"
	assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
	tags = var.tags
}
resource "aws_iam_role_policy_attachment" "userpc_ssm" {
	role       = aws_iam_role.userpc.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "userpc_cloudwatch" {
	role       = aws_iam_role.userpc.name
	policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
	statement {
		actions = ["sts:AssumeRole"]
		principals {
			type        = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}
resource "aws_network_acl" "prod_hcsa_vpc_acl" {
	vpc_id = module.aws_vpc.vpc_id
	subnet_ids = concat(module.aws_vpc.public_subnet_ids, module.aws_vpc.private_subnet_ids)

		# deny: deny-ipset, allow: allow-ipset
		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.deny_ipset.addresses
			content {
				rule_no    = 100
				protocol   = "-1"
				action     = "deny"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 200
				protocol   = "-1"
				action     = "allow"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "egress" {
			for_each = aws_wafv2_ip_set.deny_ipset.addresses
			content {
				rule_no    = 100
				protocol   = "-1"
				action     = "deny"
				cidr_block = egress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "egress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 200
				protocol   = "-1"
				action     = "allow"
				cidr_block = egress.value
				from_port  = 0
				to_port    = 0
			}
		}
	tags = merge(var.tags, { Name = "prod-hcsa-vpc-acl" })
}

resource "aws_network_acl" "onprem_hcsa_vpc_acl" {
	vpc_id = module.onprem_vpc.vpc_id
	subnet_ids = concat(module.onprem_vpc.public_subnet_ids, module.onprem_vpc.private_subnet_ids)

		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.deny_ipset.addresses
			content {
				rule_no    = 100
				protocol   = "-1"
				action     = "deny"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 200
				protocol   = "-1"
				action     = "allow"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "egress" {
			for_each = aws_wafv2_ip_set.deny_ipset.addresses
			content {
				rule_no    = 100
				protocol   = "-1"
				action     = "deny"
				cidr_block = egress.value
				from_port  = 0
				to_port    = 0
			}
		}
		dynamic "egress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 200
				protocol   = "-1"
				action     = "allow"
				cidr_block = egress.value
				from_port  = 0
				to_port    = 0
			}
		}
	tags = merge(var.tags, { Name = "onprem-hcsa-vpc-acl" })
}
resource "aws_security_group" "prod_hcsa_vpc_rds_sg" {
	name        = "prod-hcsa-vpc-rds-sg"
	description = "RDS用SG: prod-hcsa-vpc-sgから3306のみ許可"
	vpc_id      = module.aws_vpc.vpc_id

	ingress {
		from_port   = 3306
		to_port     = 3306
		protocol    = "tcp"
		security_groups = [aws_security_group.prod_hcsa_vpc_sg.id]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge(var.tags, { Name = "prod-hcsa-vpc-rds-sg" })
}
terraform {
	required_version = ">= 1.3.0"
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = ">= 4.0"
		}
	}
}

provider "aws" {
	region = var.region
}


# AWS側VPC
module "aws_vpc" {
	source          = "./modules/vpc"
	cidr_block      = var.vpc_cidr
	name            = "prod-hcsa-vpc"
	public_subnets  = var.public_subnets
	private_subnets = var.private_subnets
	azs             = var.azs
	tags            = var.tags
}

# 疑似オンプレVPC
module "onprem_vpc" {
	source          = "./modules/vpc"
	cidr_block      = var.onprem_vpc_cidr
	name            = "onprem-hcsa-vpc"
	public_subnets  = var.onprem_public_subnets
	private_subnets = var.onprem_private_subnets
	azs             = var.azs
	tags            = var.tags
}

# EC2: アプリケーションサーバ（AWS VPC内）
module "appserver" {
	source                  = "./modules/ec2"
	ami                     = "ami-0c55b159cbfafe1f0" # AWS Linux2 us-east-2例
	instance_type           = "t2.micro"
	subnet_id               = module.aws_vpc.private_subnet_ids[0]
	key_name                = null
	associate_public_ip_address = false
	name                    = "hcsa-appserver-prod-01"
	tags                    = var.tags
  security_group_ids      = [aws_security_group.prod_hcsa_vpc_sg.id]
}

# EC2: ルーター端末（疑似オンプレVPC内）
module "routerpc" {
	source                  = "./modules/ec2"
	ami                     = "ami-0d5d9d301c853a04a" # Ubuntu us-east-2例
	instance_type           = "t2.micro"
	subnet_id               = module.onprem_vpc.public_subnet_ids[0]
	key_name                = null
	associate_public_ip_address = true
	name                    = "hcsa-routerpc-dev-01"
	tags                    = var.tags
  security_group_ids      = [aws_security_group.onprem_hcsa_vpc_sg.id]
}

# EC2: ユーザー操作端末（疑似オンプレVPC内）
module "userpc" {
	source                  = "./modules/ec2"
	ami                     = "ami-0c55b159cbfafe1f0" # AWS Linux2 us-east-2例
	instance_type           = "t2.micro"
	subnet_id               = module.onprem_vpc.public_subnet_ids[1]
	key_name                = null
	associate_public_ip_address = false
	name                    = "hcsa-userpc-dev-01"
	tags                    = var.tags
  security_group_ids      = [aws_security_group.onprem_hcsa_vpc_sg.id]
}
resource "aws_security_group" "prod_hcsa_vpc_sg" {
	name        = "prod-hcsa-vpc-sg"
	description = "Allow all inbound/outbound (設計通り)"
	vpc_id      = module.aws_vpc.vpc_id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge(var.tags, { Name = "prod-hcsa-vpc-sg" })
}

resource "aws_security_group" "onprem_hcsa_vpc_sg" {
	name        = "onprem-hcsa-vpc-sg"
	description = "Allow all inbound/outbound (設計通り)"
	vpc_id      = module.onprem_vpc.vpc_id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge(var.tags, { Name = "onprem-hcsa-vpc-sg" })
}
