# vpc module variables

variable "vpc_cidr" {
	description = "VPCのCIDRブロック"
	type        = string
	default     = "10.14.0.0/16"
}
variable "public_subnet_cidr_1" {
	description = "パブリックサブネット1のCIDRブロック"
	type        = string
	default     = "10.14.1.0/24"
}
variable "public_subnet_cidr_2" {
	description = "パブリックサブネット2のCIDRブロック"
	type        = string
	default     = "10.14.2.0/24"
}


variable "az_1" {
	description = "サブネット1の配置AZ"
	type        = string
	default     = "us-east-2a"
}
variable "az_2" {
	description = "サブネット2の配置AZ"
	type        = string
	default     = "us-east-2b"
}

variable "vpc_name" {
	description = "VPC名"
	type        = string
	default     = "log-leaning-vpc"
}
variable "public_subnet_name_1" {
	description = "パブリックサブネット1の名前"
	type        = string
	default     = "log-leaning-public-subnet-1"
}
variable "public_subnet_name_2" {
	description = "パブリックサブネット2の名前"
	type        = string
	default     = "log-leaning-public-subnet-2"
}
variable "igw_name" {
	description = "インターネットゲートウェイ名"
	type        = string
	default     = "log-leaning-igw"
}
variable "route_table_name" {
	description = "ルートテーブル名"
	type        = string
	default     = "log-leaning-public-rt"
}
variable "nacl_name" {
	description = "NACL名"
	type        = string
	default     = "log-leaning-public-acl"
}
