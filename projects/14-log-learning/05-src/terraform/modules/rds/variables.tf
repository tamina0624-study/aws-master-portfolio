# rds module variables

variable "vpc_id" {
  description = "VPC ID for RDS security group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DB subnet group"
  type        = list(string)
}

variable "db_instance_identifier" {
  description = "RDS instance identifier"
  type        = string
  default     = "log-learning-db"
}

variable "engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
  default     = "log-learning-db-subnet-group"
}

variable "db_security_group_name" {
  description = "DB security group name"
  type        = string
  default     = "log-learning-db-sg"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access MySQL"
  type        = list(string)
  default     = ["10.14.0.0/16"]
}

variable "backup_retention_period" {
  description = "Automated backup retention days"
  type        = number
  default     = 7
}

variable "publicly_accessible" {
  description = "Whether DB is publicly accessible"
  type        = bool
  default     = false
}

variable "master_username" {
  description = "Master DB username"
  type        = string
  default     = "admin"
}

variable "manage_master_user_password" {
  description = "Use AWS managed master password in Secrets Manager"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting DB"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for RDS resources"
  type        = map(string)
  default = {
    Name = "log-learning-db"
  }
}
