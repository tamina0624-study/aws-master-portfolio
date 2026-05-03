variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "portfolio"
}

# 自分のグローバルIPを取得するためのデータソース
data "http" "ifconfig" {
  url = "https://ipv4.icanhazip.com"
}
