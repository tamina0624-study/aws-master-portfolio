# alb module variables

variable "alb_name" {
  description = "ALB名"
  type        = string
  default     = "log-leaning-alb"
}
variable "alb_internal" {
  description = "ALBをinternalにするか"
  type        = bool
  default     = false
}
variable "alb_sg_id" {
  description = "ALB用SGのID"
  type        = string
}
variable "subnet_1_ids" {
  description = "ALB配置サブネット1のIDリスト"
  type        = string
}
variable "subnet_2_ids" {
  description = "ALB配置サブネット2のIDリスト"
  type        = string
}

variable "ip_address_type" {
  description = "IPアドレスタイプ"
  type        = string
  default     = "ipv4"
}

variable "alb_access_logs_enabled" {
  description = "ALB access logs enabled"
  type        = bool
  default     = true
}

variable "alb_access_logs_bucket" {
  description = "S3 bucket name for ALB access logs"
  type        = string
}

variable "alb_access_logs_prefix" {
  description = "Prefix for ALB access logs"
  type        = string
  default     = "alb/access"
}

variable "alb_connection_logs_enabled" {
  description = "ALB connection logs enabled"
  type        = bool
  default     = true
}

variable "alb_connection_logs_bucket" {
  description = "S3 bucket name for ALB connection logs"
  type        = string
}

variable "alb_connection_logs_prefix" {
  description = "Prefix for ALB connection logs"
  type        = string
  default     = "alb/connection"
}

variable "tags" {
  description = "タグ"
  type        = map(string)
  default     = { Environment = "dev" }
}
variable "tg_name" {
  description = "ターゲットグループ名"
  type        = string
  default     = "log-leaning-tg"
}
variable "tg_port" {
  description = "ターゲットグループのポート"
  type        = number
  default     = 80
}
variable "tg_protocol" {
  description = "ターゲットグループのプロトコル"
  type        = string
  default     = "HTTP"
}
variable "vpc_id" {
  description = "VPCのID"
  type        = string
}
variable "tg_target_type" {
  description = "ターゲットタイプ"
  type        = string
  default     = "instance"
}
variable "tg_health_check_path" {
  description = "ヘルスチェックパス"
  type        = string
  default     = "/"
}
variable "tg_health_check_matcher" {
  description = "ヘルスチェックマッチャー"
  type        = string
  default     = "200"
}
variable "tg_health_check_interval" {
  description = "ヘルスチェック間隔"
  type        = number
  default     = 30
}
variable "tg_health_check_timeout" {
  description = "ヘルスチェックタイムアウト"
  type        = number
  default     = 5
}
variable "tg_health_check_healthy_threshold" {
  description = "ヘルスチェック正常閾値"
  type        = number
  default     = 2
}
variable "tg_health_check_unhealthy_threshold" {
  description = "ヘルスチェック異常閾値"
  type        = number
  default     = 2
}
variable "listener_port" {
  description = "リスナーポート"
  type        = number
  default     = 80
}
variable "listener_protocol" {
  description = "リスナープロトコル"
  type        = string
  default     = "HTTP"
}
variable "target_instance_id" {
  description = "ターゲットEC2のID"
  type        = string
}
