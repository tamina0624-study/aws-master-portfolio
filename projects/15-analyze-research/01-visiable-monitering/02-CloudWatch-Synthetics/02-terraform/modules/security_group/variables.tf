# security_group module variables

variable "vpc_id" {
  description = "VPCのID"
  type        = string
}
variable "ec2_web_sg_name" {
  description = "EC2用SG名"
  type        = string
  default     = "analyze-research-ec2-web-sg"
}
variable "ec2_web_sg_description" {
  description = "EC2用SG説明"
  type        = string
  default     = "EC2(Web-server)-sg"
}
variable "ec2_web_ssh_cidr_blocks" {
  description = "EC2用SGのSSH許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}
variable "ec2_web_http_cidr_blocks" {
  description = "EC2用SGのHTTP許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}
variable "ec2_web_https_cidr_blocks" {
  description = "EC2用SGのHTTPS許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}
variable "ec2_web_https_source_security_group_ids" {
  description = "EC2用SGのHTTPS許可元セキュリティグループID"
  type        = list(string)
  default     = []
}
variable "ec2_web_icmp_cidr_blocks" {
  description = "EC2用SGのICMP許可CIDR"
  type        = list(string)
  default     = []
}
variable "alb_sg_name" {
  description = "ALB用SG名"
  type        = string
  default     = "analyze-research-alb-sg"
}
variable "alb_sg_description" {
  description = "ALB用SG説明"
  type        = string
  default     = "ALB-sg"
}
variable "alb_http_cidr_blocks" {
  description = "ALB用SGのHTTP許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}
variable "alb_https_cidr_blocks" {
  description = "ALB用SGのHTTPS許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}

variable "alb_icmp_cidr_blocks" {
  description = "ALB用SGのICMP許可CIDR"
  type        = list(string)
  default     = ["211.125.140.0/24"]
}
