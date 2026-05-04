# Lambda zipファイルパス
variable "lambda_block_attacker_zip" {
	description = "攻撃元IPブロック用Lambdaのzipファイルパス"
	type        = string
	default     = "lambda_function"
}
# RDSマスター認証情報
variable "rds_master_username" {
	description = "RDSのマスターユーザー名"
	type        = string
	default     = "admin"
}

variable "rds_master_password" {
	description = "RDSのマスターパスワード"
	type        = string
	sensitive   = true
}
# 疑似オンプレ側グローバルIP（VPN用）
variable "onprem_gateway_ip" {
	description = "疑似オンプレ側のグローバルIPアドレス（VPNカスタマーゲートウェイ用）"
	type        = string
}

variable "onprem_vpc_cidr" {
	description = "疑似オンプレVPCのCIDRブロック"
	type        = string
	default     = "10.1.0.0/16"
}

variable "onprem_public_subnets" {
	description = "疑似オンプレVPCのパブリックサブネットCIDRリスト"
	type        = list(string)
	default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "onprem_private_subnets" {
	description = "疑似オンプレVPCのプライベートサブネットCIDRリスト"
	type        = list(string)
	default     = ["10.1.3.0/24", "10.1.4.0/24"]
}
variable "region" {
	description = "AWS region"
	type        = string
	default     = "us-east-2"
}

variable "vpc_cidr" {
	description = "VPC CIDR block"
	type        = string
	default     = "10.0.0.0/16"
}

variable "public_subnets" {
	description = "List of public subnet CIDRs"
	type        = list(string)
	default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
	description = "List of private subnet CIDRs"
	type        = list(string)
	default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "azs" {
	description = "List of availability zones"
	type        = list(string)
	default     = ["us-east-2a", "us-east-2b"]
}

variable "tags" {
	description = "Common tags for all resources"
	type        = map(string)
	default = {
		Project     = "Hybrid-Cloud-Connectivity-and-Security-Automation"
		Environment = "dev"
		Owner       = "your-name"
		ManagedBy   = "Terraform"
	}
}

# --- Security Group Variables ---
variable "appserver_sg_ingress" {
	description = "AppServer用SGのingressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "appserver_sg_egress" {
	description = "AppServer用SGのegressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "routerpc_sg_ingress" {
	description = "RouterPC用SGのingressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "routerpc_sg_egress" {
	description = "RouterPC用SGのegressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "userpc_sg_ingress" {
	description = "UserPC用SGのingressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "userpc_sg_egress" {
	description = "UserPC用SGのegressルール"
	type = list(object({
		from_port   = number
		to_port     = number
		protocol    = string
		cidr_blocks = list(string)
	}))
	default = []
}

variable "aws_bgp_asn" {
  description = "AWS側VGWのBGP ASN"
  type        = string
}

variable "vpn_type" {
	description = "VPN接続タイプ"
	type        = string
	default     = "ipsec.1"
}

variable "onprem_bgp_asn" {
  description = "オンプレ側カスタマーゲートウェイのBGP ASN"
  type        = string
}
