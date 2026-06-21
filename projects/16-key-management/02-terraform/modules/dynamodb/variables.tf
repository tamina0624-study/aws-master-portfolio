# dynamodb module variables

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "analyze-research-key-management"
}

variable "billing_mode" {
  description = "Billing mode: PAY_PER_REQUEST or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
  default     = "key_id"
}

variable "range_key" {
  description = "Sort key attribute name (optional)"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of DynamoDB attributes"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "key_id"
      type = "S"
    }
  ]
}

variable "read_capacity" {
  description = "Read capacity when billing_mode is PROVISIONED"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity when billing_mode is PROVISIONED"
  type        = number
  default     = 5
}

variable "ttl_enabled" {
  description = "Enable TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name"
  type        = string
  default     = "expires_at"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for table encryption (optional)"
  type        = string
  default     = null
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection for DynamoDB table"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for DynamoDB resources"
  type        = map(string)
  default     = {}
}
