# ec2 module variables

variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-078f95be0757084a3"
}
variable "instance_type" {
  description = "インスタンスタイプ"
  type        = string
  default     = "t3.micro"
}
variable "subnet_id" {
  description = "サブネットID"
  type        = string
}
variable "security_group_id" {
  description = "EC2用SGのID"
  type        = string
}
variable "key_name" {
  description = "キーペア名"
  type        = string
  default     = "my-key-pair"
}
variable "associate_public_ip_address" {
  description = "パブリックIP付与"
  type        = bool
  default     = true
}
variable "root_volume_size" {
  description = "ルートボリュームサイズ"
  type        = number
  default     = 8
}
variable "root_volume_type" {
  description = "ルートボリュームタイプ"
  type        = string
  default     = "gp2"
}
variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default = {
    Name        = "web-server"
    Environment = "dev"
  }
}
variable "user_data" {
  description = "ユーザーデータ"
  type        = string
  default     = <<-EOF
		#!/bin/bash
		yum update -y
		yum install -y httpd
		systemctl enable httpd
		systemctl start httpd
		echo "Hello from EC2" > /var/www/html/index.html
	EOF
}
