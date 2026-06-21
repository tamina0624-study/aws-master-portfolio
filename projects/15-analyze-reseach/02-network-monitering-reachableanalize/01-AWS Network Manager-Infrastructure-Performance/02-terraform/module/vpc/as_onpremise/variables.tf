# vpc module variables

variable "vpc_cidr" {
  description = "オンプレミスVPCのCIDRブロック"
  type        = string
  default     = "10.16.0.0/16"
}

variable "public_subnet_cidr_1" {
  description = "パブリックサブネット1のCIDRブロック"
  type        = string
  default     = "10.16.1.0/24"
}
variable "public_subnet_cidr_2" {
  description = "パブリックサブネット2のCIDRブロック"
  type        = string
  default     = "10.16.2.0/24"
}

variable "private_subnet_cidr_1" {
  description = "プライベートサブネット1のCIDRブロック"
  type        = string
  default     = "10.16.3.0/24"
}
variable "private_subnet_cidr_2" {
  description = "プライベートサブネット2のCIDRブロック"
  type        = string
  default     = "10.16.4.0/24"
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
  description = "オンプレミスVPC名"
  type        = string
  default     = "as_onpremise_vpc"
}


variable "public_subnet_name_1" {
  description = "パブリックサブネット1の名前"
  type        = string
  default     = "public-subnet-1_as_onpremise_vpc"
}
variable "public_subnet_name_2" {
  description = "パブリックサブネット2の名前"
  type        = string
  default     = "public-subnet-2_as_onpremise_vpc"
}

variable "private_subnet_name_1" {
  description = "プライベートサブネット1の名前"
  type        = string
  default     = "private-subnet-1_as_onpremise_vpc"
}
variable "private_subnet_name_2" {
  description = "プライベートサブネット2の名前"
  type        = string
  default     = "private-subnet-2_as_onpremise_vpc"
}




variable "igw_name" {
  description = "インターネットゲートウェイ名"
  type        = string
  default     = "igw_as_onpremise_vpc"
}



variable "route_table_name" {
  description = "ルートテーブル名"
  type        = string
  default     = "public-rt_as_onpremise_vpc"
}




variable "nacl_name" {
  description = "NACL名"
  type        = string
  default     = "public-acl_as_onpremise_vpc"
}



variable "ssm_endpoint_security_group_name" {
  description = "SSM Session Manager用VPC Endpoint SG名"
  type        = string
  default     = "analyze-research-ssm-vpce-sg"
}

variable "ssm_vpc_endpoint_name" {
  description = "SSM endpoint名"
  type        = string
  default     = "vpce-ssm-as_onpremise_vpc"
}

variable "ssmmessages_vpc_endpoint_name" {
  description = "SSMMessages endpoint名"
  type        = string
  default     = "vpce-ssmmessages-as_onpremise_vpc"
}

variable "ec2messages_vpc_endpoint_name" {
  description = "EC2Messages endpoint名"
  type        = string
  default     = "vpce-ec2messages-as_onpremise_vpc"
}

variable "customer_gateway_bgp_asn" {
  description = "Customer Gateway のBGP ASN"
  type        = number
  default     = 65000
}

variable "customer_gateway_name" {
  description = "Customer Gateway 名"
  type        = string
  default     = "cgw-as_onpremise_vpc"
}
