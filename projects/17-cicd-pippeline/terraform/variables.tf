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
