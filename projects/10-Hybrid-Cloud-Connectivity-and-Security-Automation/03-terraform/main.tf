# Ubuntu 24.04 (最新) AMIデータソース
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

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# --- インターネットゲートウェイ ---
resource "aws_internet_gateway" "prod_hcsa_vpc_igw" {
	vpc_id = module.aws_vpc.vpc_id
	tags   = merge(var.tags, { Name = "prod-hcsa-vpc-igw" })
}

resource "aws_internet_gateway" "onprem_hcsa_vpc_igw" {
	vpc_id = module.onprem_vpc.vpc_id
	tags   = merge(var.tags, { Name = "onprem-hcsa-vpc-igw" })
}
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
	addresses          = ["255.255.255.255/32"]
	tags = merge(var.tags, { Name = "deny-ipset" })
}

# --- Lambda（攻撃元IPブロック） ---
resource "aws_lambda_function" "block_attacker_ip_port" {
	function_name = "hcsa-lambda-block_attacker_ip_port"
	role          = aws_iam_role.lambda_block_attacker.arn
	handler       = "lambda_function.lambda_handler"
	runtime       = "python3.8"
	timeout       = 3
	memory_size   = 128
	filename      = "lambda_function.zip"
	source_code_hash = filebase64sha256("lambda_function.zip")
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
	subnet_ids = [module.aws_vpc.private_subnet_ids[0], module.aws_vpc.private_subnet_ids[1]]
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
	password                = var.rds_master_password != "" ? var.rds_master_password : trimspace(data.local_file.rds_password.content)
	db_name                 = "hcsa_db"
	multi_az                = false
	availability_zone       = "us-east-2a"
	publicly_accessible     = false
	skip_final_snapshot     = true
	deletion_protection     = false
	tags                    = merge(var.tags, { Name = "prod-hcsa-vpc-rds" })
	iam_database_authentication_enabled = true
}

# --- RDSパスワードを外部ファイルから取得 ---
data "local_file" "rds_password" {
  filename = "${path.module}/modules/Secret/securet"
}
# --- AWS側VPC: パブリックサブネット用ルートテーブル ---
resource "aws_route_table" "aws_public" {
		vpc_id = module.aws_vpc.vpc_id
		tags   = merge(var.tags, { Name = "prod-hcsa-public-rtb" })
}

# --- AWS側VPC: 0.0.0.0/0 → IGWルート ---
resource "aws_route" "aws_public_igw" {
	route_table_id         = aws_route_table.aws_public.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = aws_internet_gateway.prod_hcsa_vpc_igw.id
}

# --- オンプレVPC: 0.0.0.0/0 → IGWルート ---
resource "aws_route" "onprem_public_igw" {
	route_table_id         = aws_route_table.onprem.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = aws_internet_gateway.onprem_hcsa_vpc_igw.id
}


resource "aws_route_table_association" "aws_public" {
	count          = length(module.aws_vpc.public_subnet_ids)
	subnet_id      = module.aws_vpc.public_subnet_ids[count.index]
	route_table_id = aws_route_table.aws_public.id
}

# オンプレ側ルーター用の固定パブリックIP (Elastic IP)
resource "aws_eip" "onprem_router_eip" {
  domain = "vpc"
  tags = { Name = "onprem-hcsa-Router-EIP" }
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
	vpc_id  = module.aws_vpc.vpc_id
	amazon_side_asn = var.aws_bgp_asn
	tags    = merge(var.tags, { Name = "prod-hcsa-vgw" })
}

# VPN接続
resource "aws_vpn_connection" "onprem" {
	vpn_gateway_id      = aws_vpn_gateway.prod_hcsa_vgw.id
	customer_gateway_id = aws_customer_gateway.onprem.id
	type                = var.vpn_type
	static_routes_only  = false
	tags                = merge(var.tags, { Name = "onprem-vpn-connection" })
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
			ingress {
				rule_no    = 10
				protocol   = "icmp"
				action     = "allow"
				cidr_block = "0.0.0.0/0"
				from_port  = 0
				to_port    = 0
				icmp_type = -1
				icmp_code = -1
			}
			ingress {
				rule_no    = 20
				protocol   = 6
				action     = "allow"
				cidr_block = "164.70.177.0/24"
				from_port  = 22
				to_port    = 22
			}
			ingress {
				rule_no    = 30
				protocol   = 6
				action     = "allow"
				cidr_block = "0.0.0.0/0"
				from_port  = 1024
				to_port    = 65535
			}
	vpc_id = module.aws_vpc.vpc_id
		# deny: deny-ipset, allow: allow-ipset
		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 100 + index(tolist(aws_wafv2_ip_set.allow_ipset.addresses), ingress.value)
				protocol   = "-1"
				action     = "allow"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
	dynamic "ingress" {
		for_each = aws_wafv2_ip_set.deny_ipset.addresses
		content {
			rule_no    = 200 + index(tolist(aws_wafv2_ip_set.deny_ipset.addresses), ingress.value)
			protocol   = "-1"
			action     = "deny"
			cidr_block = ingress.value
			from_port  = 0
			to_port    = 0
		}
	}
					ingress {
				rule_no    = 199
				protocol   = 17
				action     = "allow"
				cidr_block = "3.150.10.134/32"
				from_port  = 0
				to_port    = 0
			}


			egress {
			rule_no    = 100
			protocol   = "-1"
			action     = "allow"
			cidr_block = "0.0.0.0/0"
			from_port  = 0
			to_port    = 0
		}
		egress {
			rule_no    = 200
			protocol   = "-1"
			action     = "deny"
			cidr_block = "0.0.0.0/0"
			from_port  = 0
			to_port    = 0
		}

	tags = merge(var.tags, { Name = "prod-hcsa-vpc-acl" })
}

resource "aws_network_acl" "onprem_hcsa_vpc_acl" {
			ingress {
				rule_no    = 10
				protocol   = "icmp"
				action     = "allow"
				cidr_block = "0.0.0.0/0"
				from_port  = 0
				to_port    = 0
				icmp_type = -1
				icmp_code = -1
			}
			ingress {
				rule_no    = 20
				protocol   = 6
				action     = "allow"
				cidr_block = "164.70.177.0/24"
				from_port  = 22
				to_port    = 22
			}
			ingress {
				rule_no    = 30
				protocol   = 6
				action     = "allow"
				cidr_block = "0.0.0.0/0"
				from_port  = 1024
				to_port    = 65535
			}
	vpc_id = module.onprem_vpc.vpc_id
	subnet_ids = concat(module.onprem_vpc.public_subnet_ids, module.onprem_vpc.private_subnet_ids)

		dynamic "ingress" {
			for_each = aws_wafv2_ip_set.allow_ipset.addresses
			content {
				rule_no    = 100 + index(tolist(aws_wafv2_ip_set.allow_ipset.addresses), ingress.value)
				protocol   = "-1"
				action     = "allow"
				cidr_block = ingress.value
				from_port  = 0
				to_port    = 0
			}
		}
	dynamic "ingress" {
		for_each = aws_wafv2_ip_set.deny_ipset.addresses
		content {
			rule_no    = 200 + index(tolist(aws_wafv2_ip_set.deny_ipset.addresses), ingress.value)
			protocol   = "-1"
			action     = "deny"
			cidr_block = ingress.value
			from_port  = 0
			to_port    = 0
		}
	}
					ingress {
				rule_no    = 198
				protocol   = 17
				action     = "allow"
				cidr_block = "16.58.221.50/32"
				from_port  = 0
				to_port    = 0
			}


				ingress {
				rule_no    = 199
				protocol   = 17
				action     = "allow"
				cidr_block = "18.188.137.116/32"
				from_port  = 0
				to_port    = 0
			}

		egress {
			rule_no    = 100
			protocol   = "-1"
			action     = "allow"
			cidr_block = "0.0.0.0/0"
			from_port  = 0
			to_port    = 0
		}
		egress {
			rule_no    = 200
			protocol   = "-1"
			action     = "deny"
			cidr_block = "0.0.0.0/0"
			from_port  = 0
			to_port    = 0
		}
	tags = merge(var.tags, { Name = "onprem-hcsa-vpc-acl" })
}
resource "aws_security_group" "prod_hcsa_vpc_rds_sg" {
	name        = "prod-hcsa-vpc-rds-sg"
	description = "RDS-SG:prod-hcsa-vpc-sg:3306"
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



# --- EC2用インスタンスプロファイル ---
resource "aws_iam_instance_profile" "appserver" {
	name = "hcsa-ec2-appserver-profile"
	role = aws_iam_role.appserver.name
}
resource "aws_iam_instance_profile" "routerpc" {
	name = "hcsa-ec2-routerpc-profile"
	role = aws_iam_role.routerpc.name
}
resource "aws_iam_instance_profile" "userpc" {
	name = "hcsa-ec2-userpc-profile"
	role = aws_iam_role.userpc.name
}

# EC2: アプリケーションサーバ（AWS VPC内）
module "appserver" {
	source                  = "./modules/ec2"
	ami                     = data.aws_ami.amazon_linux_2023.id # AWS Linux2 us-east-2例
	instance_type           = "t2.micro"
	subnet_id               = module.aws_vpc.public_subnet_ids[0]
	key_name                = "id_rsa_aws"
	associate_public_ip_address = true
	name                    = "hcsa-appserver-prod-01"
	tags                    = var.tags
	security_group_ids      = [aws_security_group.prod_hcsa_vpc_sg.id]
	iam_instance_profile    = aws_iam_instance_profile.appserver.name
	userdata = templatefile(
		"${path.module}/modules/ec2/appserver_userdata.sh.tpl",
		{
			rds_endpoint = aws_db_instance.prod_hcsa_rds.endpoint
			rds_user     = var.rds_master_username
			rds_pass     = var.rds_master_password != "" ? var.rds_master_password : trimspace(data.local_file.rds_password.content)
			rds_db       = "hcsa_db"
		}
	)
}

# EC2: ルーター端末（疑似オンプレVPC内）
module "routerpc" {
	source                  = "./modules/ec2"
	ami                     = data.aws_ami.ubuntu.id
	instance_type           = "t2.micro"
	subnet_id               = module.onprem_vpc.public_subnet_ids[0]
	key_name                = "id_rsa_aws"
	associate_public_ip_address = true
	name                    = "hcsa-routerpc-dev-01"
	tags                    = var.tags
	security_group_ids      = [aws_security_group.onprem_hcsa_vpc_sg.id]
	iam_instance_profile    = aws_iam_instance_profile.routerpc.name
	userdata = templatefile(
		"${path.module}/modules/ec2/vpn_setup.sh.tpl",
		{
			tun1_outside_ip         = aws_vpn_connection.onprem.tunnel1_address
			tun2_outside_ip         = aws_vpn_connection.onprem.tunnel2_address
			onprem_public_ip        = aws_eip.onprem_router_eip.public_ip
			tun1_psk                = aws_vpn_connection.onprem.tunnel1_preshared_key
			tun2_psk                = aws_vpn_connection.onprem.tunnel2_preshared_key
			tun1_inside_cgw_ip      = aws_vpn_connection.onprem.tunnel1_cgw_inside_address
			tun1_inside_vgw_ip      = aws_vpn_connection.onprem.tunnel1_vgw_inside_address
			tun2_inside_cgw_ip      = aws_vpn_connection.onprem.tunnel2_cgw_inside_address
			tun2_inside_vgw_ip      = aws_vpn_connection.onprem.tunnel2_vgw_inside_address
			tun1_inside_cidr_block  = aws_vpn_connection.onprem.tunnel1_inside_cidr
			tun2_inside_cidr_block  = aws_vpn_connection.onprem.tunnel2_inside_cidr
			aws_bgp_asn            = var.aws_bgp_asn
			onprem_bgp_asn         = var.onprem_bgp_asn
		}
	)
}

# カスタマーゲートウェイ（オンプレ想定）
resource "aws_customer_gateway" "onprem" {
	bgp_asn    = var.onprem_bgp_asn
	ip_address = aws_eip.onprem_router_eip.public_ip
	type       = var.vpn_type
	tags       = merge(var.tags, { Name = "onprem-cgw" })
}



# エラスティックIPの紐づけ処理
resource "aws_eip_association" "onprem_router_eip_assoc" {
	instance_id   = module.routerpc.instance_id
	allocation_id = aws_eip.onprem_router_eip.id
}


# EC2: ユーザー操作端末（疑似オンプレVPC内）
module "userpc" {
	source                  = "./modules/ec2"
	ami                     = data.aws_ami.amazon_linux_2023.id # AWS Linux2 us-east-2
	instance_type           = "t2.micro"
	subnet_id               = module.onprem_vpc.public_subnet_ids[0]
	key_name                = "id_rsa_aws"
	associate_public_ip_address = true
	name                    = "hcsa-userpc-dev-01"
	tags                    = var.tags
	security_group_ids      = [aws_security_group.onprem_hcsa_vpc_sg.id]
	iam_instance_profile    = aws_iam_instance_profile.userpc.name
}
resource "aws_security_group" "prod_hcsa_vpc_sg" {
				ingress {
					from_port   = 22
					to_port     = 22
					protocol    = "tcp"
					cidr_blocks = ["164.70.177.0/24"]
				}
		ingress {
			from_port   = -1
			to_port     = -1
			protocol    = "icmp"
			cidr_blocks = ["0.0.0.0/0"]
		}
	name        = "prod-hcsa-vpc-sg"
	description = "Allow all inbound/outbound"
	vpc_id      = module.aws_vpc.vpc_id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = aws_wafv2_ip_set.allow_ipset.addresses
	}

	ingress {
		from_port   = 500
		to_port     = 500
		protocol    = "udp"
		cidr_blocks = ["3.150.10.134/32"]
	}

	ingress {
		from_port   = 4500
		to_port     = 4500
		protocol    = "udp"
		cidr_blocks = ["3.150.10.134/32"]
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
				ingress {
					from_port   = 22
					to_port     = 22
					protocol    = "tcp"
					cidr_blocks = ["164.70.177.0/24"]
				}
				ingress {
					from_port   = 22
					to_port     = 22
					protocol    = "tcp"
					cidr_blocks = ["164.70.177.0/24"]
				}
		ingress {
			from_port   = -1
			to_port     = -1
			protocol    = "icmp"
			cidr_blocks = ["0.0.0.0/0"]
		}
		ingress {
			from_port   = -1
			to_port     = -1
			protocol    = "icmp"
			cidr_blocks = ["0.0.0.0/0"]
		}
		ingress {
			protocol   = "icmp"
			cidr_blocks = ["0.0.0.0/0"]
			from_port  = -1
			to_port    = -1
		}
		ingress {
			protocol   = "icmp"
			cidr_blocks = ["0.0.0.0/0"]
			from_port  = -1
			to_port    = -1
		}
	name        = "onprem-hcsa-vpc-sg"
	description = "Allow all inbound/outbound"
	vpc_id      = module.onprem_vpc.vpc_id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = aws_wafv2_ip_set.allow_ipset.addresses
	}

	ingress {
		from_port   = 500
		to_port     = 500
		protocol    = "udp"
		cidr_blocks = ["16.58.221.50/32","18.188.137.116/32"]
	}

	ingress {
		from_port   = 4500
		to_port     = 4500
		protocol    = "udp"
		cidr_blocks = ["16.58.221.50/32","18.188.137.116/32"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = merge(var.tags, { Name = "onprem-hcsa-vpc-sg" })
}
