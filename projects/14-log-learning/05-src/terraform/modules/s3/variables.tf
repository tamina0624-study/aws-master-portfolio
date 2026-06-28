variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "bucket_name" {
  description = "S3バケット名"
  type        = string
  default     = "loglearning-bucket"

}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}
