terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  # Avoid intermittent bucket-host DNS lookup failures on some local resolvers.
  s3_use_path_style = true
  default_tags {
    tags = {
      Project     = "LogLeaning"
      Environment = "Portfolio"
      ManagedBy   = "Terraform"
    }
  }
}
