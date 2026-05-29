# route53 module variables

variable "zone_name" {
	description = "ホストゾーン名（ドメイン名）"
	type        = string
}
variable "zone_comment" {
	description = "ホストゾーンのコメント"
	type        = string
	default     = "Managed by Terraform"
}
variable "record_name" {
	description = "Aレコード名"
	type        = string
	default     = "@"
}
variable "alb_dns_name" {
	description = "ALBのDNS名"
	type        = string
}
variable "alb_zone_id" {
	description = "ALBのZone ID"
	type        = string
}
variable "evaluate_target_health" {
	description = "ターゲットヘルス評価有効化"
	type        = bool
	default     = true
}
variable "ttl" {
	description = "TTL"
	type        = number
	default     = 300
}
variable "record_comment" {
	description = "Aレコードのコメント"
	type        = string
	default     = "Managed by Terraform"
}
