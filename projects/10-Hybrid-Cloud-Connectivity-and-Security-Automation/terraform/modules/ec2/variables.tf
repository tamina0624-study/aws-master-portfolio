variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name tag for the instance"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "userdata" {
  description = "EC2インスタンスのuser_data（シェルスクリプト等）"
  type        = string
  default     = null
}
