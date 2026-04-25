# projects/04-enterprise-landing-zone/variables.tf

variable "aws_region" {
  description = "リソースを展開するAWSリージョン"
  type        = string
  default     = "us-east-2" # 今までと同じオハイオリージョンを使用
}

variable "project_name" {
  description = "プロジェクトのプレフィックス"
  type        = string
  default     = "portfolio-lz" # lz = Landing Zone
}
