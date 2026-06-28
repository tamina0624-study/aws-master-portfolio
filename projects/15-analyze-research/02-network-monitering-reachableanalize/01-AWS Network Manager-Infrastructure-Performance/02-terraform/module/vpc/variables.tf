# vpc module variables

variable "transit_gateway_name" {
  description = "Transit Gateway の名前"
  type        = string
  default     = "analyze-research-tgw"
}

variable "vpc_cidr_aws_vpc1" {
  description = "VPC1のCIDRブロック"
  type        = string
  default     = "10.14.0.0/16"
}
variable "vpc_cidr_aws_vpc2" {
  description = "VPC2のCIDRブロック"
  type        = string
  default     = "10.15.0.0/16"
}
variable "vpc_cidr_as_onpremise" {
  description = "オンプレミスVPCのCIDRブロック"
  type        = string
  default     = "10.16.0.0/16"
}

variable "public_subnet_cidr_1_aws_vpc1" {
  description = "パブリックサブネット1のCIDRブロック"
  type        = string
  default     = "10.14.1.0/24"
}
variable "public_subnet_cidr_2_aws_vpc1" {
  description = "パブリックサブネット2のCIDRブロック"
  type        = string
  default     = "10.14.2.0/24"
}

variable "private_subnet_cidr_1_aws_vpc1" {
  description = "プライベートサブネット1のCIDRブロック"
  type        = string
  default     = "10.14.3.0/24"
}
variable "private_subnet_cidr_2_aws_vpc1" {
  description = "プライベートサブネット2のCIDRブロック"
  type        = string
  default     = "10.14.4.0/24"
}

variable "public_subnet_cidr_1_aws_vpc2" {
  description = "パブリックサブネット1のCIDRブロック"
  type        = string
  default     = "10.15.1.0/24"
}
variable "public_subnet_cidr_2_aws_vpc2" {
  description = "パブリックサブネット2のCIDRブロック"
  type        = string
  default     = "10.15.2.0/24"
}

variable "private_subnet_cidr_1_aws_vpc2" {
  description = "プライベートサブネット1のCIDRブロック"
  type        = string
  default     = "10.15.3.0/24"
}
variable "private_subnet_cidr_2_aws_vpc2" {
  description = "プライベートサブネット2のCIDRブロック"
  type        = string
  default     = "10.15.4.0/24"
}

variable "public_subnet_cidr_1_as_onpremise" {
  description = "パブリックサブネット1のCIDRブロック"
  type        = string
  default     = "10.16.1.0/24"
}
variable "public_subnet_cidr_2_as_onpremise" {
  description = "パブリックサブネット2のCIDRブロック"
  type        = string
  default     = "10.16.2.0/24"
}

variable "private_subnet_cidr_1_as_onpremise" {
  description = "プライベートサブネット1のCIDRブロック"
  type        = string
  default     = "10.16.3.0/24"
}
variable "private_subnet_cidr_2_as_onpremise" {
  description = "プライベートサブネット2のCIDRブロック"
  type        = string
  default     = "10.16.4.0/24"
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

variable "vpc_name_aws_vpc1" {
  description = "VPC1名"
  type        = string
  default     = "aws_vpc1"
}

variable "vpc_name_aws_vpc2" {
  description = "VPC2名"
  type        = string
  default     = "aws_vpc2"
}

variable "vpc_name_as_onpremise" {
  description = "オンプレミスVPC名"
  type        = string
  default     = "as_onpremise"
}




variable "public_subnet_name_1_aws_vpc1" {
  description = "パブリックサブネット1の名前"
  type        = string
  default     = "public-subnet-1_aws_vpc1"
}
variable "public_subnet_name_2_aws_vpc1" {
  description = "パブリックサブネット2の名前"
  type        = string
  default     = "public-subnet-2_aws_vpc1"
}

variable "private_subnet_name_1_aws_vpc1" {
  description = "プライベートサブネット1の名前"
  type        = string
  default     = "private-subnet-1_aws_vpc1"
}
variable "private_subnet_name_2_aws_vpc1" {
  description = "プライベートサブネット2の名前"
  type        = string
  default     = "private-subnet-2_aws_vpc1"
}


variable "public_subnet_name_1_aws_vpc2" {
  description = "パブリックサブネット1の名前"
  type        = string
  default     = "public-subnet-1_aws_vpc2"
}
variable "public_subnet_name_2_aws_vpc2" {
  description = "パブリックサブネット2の名前"
  type        = string
  default     = "public-subnet-2_aws_vpc2"
}

variable "private_subnet_name_1_aws_vpc2" {
  description = "プライベートサブネット1の名前"
  type        = string
  default     = "private-subnet-1_aws_vpc2"
}
variable "private_subnet_name_2_aws_vpc2" {
  description = "プライベートサブネット2の名前"
  type        = string
  default     = "private-subnet-2_aws_vpc2"
}


variable "public_subnet_name_1_as_onpremise" {
  description = "パブリックサブネット1の名前"
  type        = string
  default     = "public-subnet-1_as_onpremise"
}
variable "public_subnet_name_2_as_onpremise" {
  description = "パブリックサブネット2の名前"
  type        = string
  default     = "public-subnet-2_as_onpremise"
}

variable "private_subnet_name_1_as_onpremise" {
  description = "プライベートサブネット1の名前"
  type        = string
  default     = "private-subnet-1_as_onpremise"
}
variable "private_subnet_name_2_as_onpremise" {
  description = "プライベートサブネット2の名前"
  type        = string
  default     = "private-subnet-2_as_onpremise"
}



variable "igw_name_aws_vpc1" {
  description = "インターネットゲートウェイ名"
  type        = string
  default     = "igw_aws_vpc1"
}

variable "igw_name_aws_vpc2" {
  description = "インターネットゲートウェイ名"
  type        = string
  default     = "igw_aws_vpc2"
}
variable "igw_name_as_onpremise" {
  description = "インターネットゲートウェイ名"
  type        = string
  default     = "igw_as_onpremise"
}



variable "route_table_name_aws_vpc1" {
  description = "ルートテーブル名"
  type        = string
  default     = "public-rt_aws_vpc1"
}

variable "route_table_name_aws_vpc2" {
  description = "ルートテーブル名"
  type        = string
  default     = "public-rt_aws_vpc2"
}
variable "route_table_name_as_onpremise" {
  description = "ルートテーブル名"
  type        = string
  default     = "public-rt_as_onpremise"
}




variable "nacl_name_aws_vpc1" {
  description = "NACL名"
  type        = string
  default     = "public-acl_aws_vpc1"
}

variable "nacl_name_aws_vpc2" {
  description = "NACL名"
  type        = string
  default     = "public-acl_aws_vpc2"
}

variable "nacl_name_as_onpremise" {
  description = "NACL名"
  type        = string
  default     = "public-acl_as_onpremise"
}


variable "ssm_endpoint_security_group_name" {
  description = "SSM Session Manager用VPC Endpoint SG名"
  type        = string
  default     = "analyze-research-ssm-vpce-sg"
}

variable "ssm_vpc_endpoint_name_aws_vpc1" {
  description = "SSM endpoint名"
  type        = string
  default     = "vpce-ssm-aws-vpc1"
}

variable "ssmmessages_vpc_endpoint_name_aws_vpc1" {
  description = "SSMMessages endpoint名"
  type        = string
  default     = "vpce-ssmmessages-aws-vpc1"
}

variable "ec2messages_vpc_endpoint_name_aws_vpc1" {
  description = "EC2Messages endpoint名"
  type        = string
  default     = "vpce-ec2messages-aws-vpc1"
}
