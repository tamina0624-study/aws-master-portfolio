variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "name" {
  description = "VPC Name"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
