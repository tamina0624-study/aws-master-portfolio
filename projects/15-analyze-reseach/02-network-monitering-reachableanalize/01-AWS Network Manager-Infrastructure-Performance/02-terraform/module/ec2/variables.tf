# ec2 module variables

variable "vpc" {
  description = "VPC情報"
  type        = any
  default     = null
}


variable "subnet_name_tag_aws_vpc1" {
  description = "aws_vpc1 で選択するサブネットの Name タグ"
  type        = string
  default     = "public-subnet-1_aws_vpc1"
}

variable "subnet_name_tag_aws_vpc2" {
  description = "aws_vpc2 で選択するサブネットの Name タグ"
  type        = string
  default     = "public-subnet-1_aws_vpc2"
}

variable "subnet_name_tag_as_onpremise" {
  description = "as_onpremise で選択するサブネットの Name タグ"
  type        = string
  default     = "public-subnet-1_as_onpremise"
}

variable "ec2_ssm_role_name" {
  description = "Session Manager用EC2 IAMロール名"
  type        = string
  default     = "analyze-research-ec2-ssm-role"
}

variable "ec2_ssm_instance_profile_name" {
  description = "Session Manager用EC2インスタンスプロファイル名"
  type        = string
  default     = "analyze-research-ec2-ssm-instance-profile"
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default = {
    Name        = "web-server"
    Environment = "dev"
  }
}
