# waf module variables

variable "waf_name" {
  description = "WAF名"
  type        = string
  default     = "log-learning-waf"
}
variable "waf_description" {
  description = "WAF説明"
  type        = string
  default     = "Managed by Terraform"
}
variable "waf_scope" {
  description = "WAFスコープ(REGIONAL/...)"
  type        = string
  default     = "REGIONAL"
}
variable "rule_name" {
  description = "ルール名"
  type        = string
  default     = "AWS-AWSManagedRulesCommonRuleSet"
}
variable "rule_priority" {
  description = "ルール優先度"
  type        = number
  default     = 1
}
variable "rule_group_name" {
  description = "マネージドルールグループ名"
  type        = string
  default     = "AWSManagedRulesCommonRuleSet"
}
variable "rule_group_vendor" {
  description = "マネージドルールグループベンダー"
  type        = string
  default     = "AWS"
}
variable "rule_sampled_requests_enabled" {
  description = "ルール単位サンプリング有効化"
  type        = bool
  default     = true
}
variable "rule_cloudwatch_metrics_enabled" {
  description = "ルール単位メトリクス有効化"
  type        = bool
  default     = true
}
variable "rule_metric_name" {
  description = "ルール単位メトリクス名"
  type        = string
  default     = "waf-rule-metric"
}
variable "waf_sampled_requests_enabled" {
  description = "WAF全体サンプリング有効化"
  type        = bool
  default     = true
}
variable "waf_cloudwatch_metrics_enabled" {
  description = "WAF全体メトリクス有効化"
  type        = bool
  default     = true
}
variable "waf_metric_name" {
  description = "WAF全体メトリクス名"
  type        = string
  default     = "waf-metric"
}
variable "tags" {
  description = "タグ"
  type        = map(string)
  default     = { Environment = "dev" }
}
variable "alb_arn" {
  description = "ALBのARN"
  type        = string
}
