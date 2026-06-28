variable "vpc" {
  description = "vpc定義"
  type        = any
  default     = null
}

variable "ec2_ssm_role_name" {
  description = "共通で利用するSession Manager用EC2 IAMロール名"
  type        = string
  default     = "analyze-research-ec2-ssm-role-common"
}

variable "ec2_ssm_instance_profile_name" {
  description = "共通で利用するSession Manager用EC2インスタンスプロファイル名"
  type        = string
  default     = "analyze-research-ec2-ssm-instance-profile-common"
}

variable "tags" {
  description = "共通IAMリソースのタグ"
  type        = map(string)
  default = {
    Name        = "ec2-ssm-common"
    Environment = "dev"
  }
}
