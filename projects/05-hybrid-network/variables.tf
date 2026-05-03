variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "onprem_vpc_cidr" {
  description = "CIDR block for Simulated On-Premises VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "aws_bgp_asn" {
  description = "BGP ASN for AWS VGW"
  type        = number
  default     = 64512
}

variable "onprem_bgp_asn" {
  description = "BGP ASN for On-Premises Router (CGW)"
  type        = number
  default     = 65000
}
