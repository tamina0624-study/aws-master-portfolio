variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cicd-learning"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "sample-app"
}

variable "allowed_source_cidr" {
  description = "CIDR allowed to access S3 bucket"
  type        = string
  default     = "164.70.177.0/24"
}

variable "ip_restriction_exempt_principal_arns" {
  description = "Principal ARNs exempt from Source IP restriction"
  type        = list(string)
  default     = [
    "arn:aws:iam::638892640336:role/GitHubActionsRole"
  ]
}
