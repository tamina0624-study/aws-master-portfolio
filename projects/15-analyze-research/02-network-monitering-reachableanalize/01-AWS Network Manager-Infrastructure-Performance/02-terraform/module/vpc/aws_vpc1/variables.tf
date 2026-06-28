# vpc module variables

variable "vpc_cidr" {
  description = "VPC1のCIDRブロック"
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

variable "private_subnet_cidr_1" {
  description = "プライベートサブネット1のCIDRブロック"
  type        = string
  default     = "10.14.3.0/24"
}
variable "private_subnet_cidr_2" {
  description = "プライベートサブネット2のCIDRブロック"
  type        = string
  default     = "10.14.4.0/24"
}


variable "az_1" {
  description = "サブネット1の配置AZ"
  type        = string
  default     = "ap-northeast-1a"
}
variable "az_2" {
  description = "サブネット2の配置AZ"
  type        = string
  default     = "ap-northeast-1c"
}

variable "vpc_name" {
  description = "VPC1名"
  type        = string
  default     = "aws_vpc1"
}


variable "public_subnet_name_1" {
  description = "パブリックサブネット1の名前"
  type        = string
  default     = "public-subnet-1_aws_vpc1"
}
variable "public_subnet_name_2" {
  description = "パブリックサブネット2の名前"
  type        = string
  default     = "public-subnet-2_aws_vpc1"
}

variable "private_subnet_name_1" {
  description = "プライベートサブネット1の名前"
  type        = string
  default     = "private-subnet-1_aws_vpc1"
}
variable "private_subnet_name_2" {
  description = "プライベートサブネット2の名前"
  type        = string
  default     = "private-subnet-2_aws_vpc1"
}




variable "igw_name" {
  description = "インターネットゲートウェイ名"
  type        = string
  default     = "igw_aws_vpc1"
}



variable "route_table_name" {
  description = "ルートテーブル名"
  type        = string
  default     = "public-rt_aws_vpc1"
}

variable "transit_gateway_id" {
  description = "VPC1 のデフォルトルート先となる Transit Gateway ID"
  type        = string
}




variable "nacl_name" {
  description = "NACL名"
  type        = string
  default     = "public-acl_aws_vpc1"
}



variable "ssm_endpoint_security_group_name" {
  description = "SSM Session Manager用VPC Endpoint SG名"
  type        = string
  default     = "analyze-research-ssm-vpce-sg"
}

variable "ssm_vpc_endpoint_name" {
  description = "SSM endpoint名"
  type        = string
  default     = "vpce-ssm-aws-vpc1"
}

variable "ssmmessages_vpc_endpoint_name" {
  description = "SSMMessages endpoint名"
  type        = string
  default     = "vpce-ssmmessages-aws-vpc1"
}

variable "ec2messages_vpc_endpoint_name" {
  description = "EC2Messages endpoint名"
  type        = string
  default     = "vpce-ec2messages-aws-vpc1"
}
