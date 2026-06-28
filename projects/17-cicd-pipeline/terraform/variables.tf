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

variable "create_bucket" {
  description = "Whether Terraform should create the S3 bucket and related resources"
  type        = bool
  default     = true
}

variable "allowed_source_cidr" {
  description = "CIDR allowed to access S3 bucket"
  type        = string
  default     = "211.125.140.0/24"
}

variable "ip_restriction_exempt_principal_arns" {
  description = "Principal ARNs exempt from Source IP restriction"
  type        = list(string)
  default     = []
}

variable "create_ec2_test" {
  description = "Whether Terraform should create isolated EC2 resources for destroy testing"
  type        = bool
  default     = false
}

variable "ec2_test_instance_type" {
  description = "Instance type for the EC2 destroy test"
  type        = string
  default     = "t2.micro"
}

variable "ec2_test_vpc_cidr" {
  description = "CIDR block for the isolated EC2 test VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "ec2_test_subnet_cidr" {
  description = "CIDR block for the isolated EC2 test subnet"
  type        = string
  default     = "10.42.1.0/24"
}

# ─────────────────────────────────────────────
# ECR / ECS 変数
# ─────────────────────────────────────────────
variable "create_ecr" {
  description = "Whether to create the ECR repository"
  type        = bool
  default     = false
}

variable "create_ecs" {
  description = "Whether to create ECS Fargate resources (cluster, service, task definition)"
  type        = bool
  default     = false
}

variable "ecs_vpc_id" {
  description = "VPC ID for ECS tasks (required when create_ecs = true)"
  type        = string
  default     = ""
}

variable "ecs_subnet_ids" {
  description = "Subnet IDs for ECS tasks (required when create_ecs = true)"
  type        = list(string)
  default     = []
}

variable "ecs_container_port" {
  description = "Container port exposed by the application"
  type        = number
  default     = 8080
}
