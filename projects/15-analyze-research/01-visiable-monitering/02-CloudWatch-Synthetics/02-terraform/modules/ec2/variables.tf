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

variable "ec2_ssm_role_name" {
  description = "Session Manager用EC2 IAMロール名"
  type        = string
  default     = "analyze-research-ec2-ssm-role"
}

variable "ec2_ssm_instance_profile_name" {
  description = "Session Manager用EC2インスタンスプロファイル名"
  type        = string
  default     = "analyze-research-ec2-ssm-instance-profile"
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
    set -euxo pipefail

    if ! command -v python3 >/dev/null 2>&1; then
      echo "python3 is required but not found" >&2
      exit 1
    fi

    mkdir -p /opt/simple-web
    cat <<'HTML' > /opt/simple-web/index.html
    <html><body><h1>Hello from EC2</h1></body></html>
    HTML

    cat <<'UNIT' > /etc/systemd/system/simple-web.service
    [Unit]
    Description=Simple Python Web Server
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/bin/python3 -m http.server 80 --bind 0.0.0.0 --directory /opt/simple-web
    Restart=always

    [Install]
    WantedBy=multi-user.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now simple-web.service
	EOF
}
