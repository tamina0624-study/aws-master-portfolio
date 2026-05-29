# WAF WebACLリソース定義
resource "aws_wafv2_web_acl" "this" {
	name        = var.waf_name
	description = var.waf_description
	scope       = var.waf_scope
	default_action {
		allow {}
	}
	rule {
		name     = var.rule_name
		priority = var.rule_priority
		override_action {
			none {}
		}
		statement {
			managed_rule_group_statement {
				name        = var.rule_group_name
				vendor_name = var.rule_group_vendor
			}
		}
		visibility_config {
			sampled_requests_enabled    = var.rule_sampled_requests_enabled
			cloudwatch_metrics_enabled  = var.rule_cloudwatch_metrics_enabled
			metric_name                 = var.rule_metric_name
		}
	}
	visibility_config {
		sampled_requests_enabled    = var.waf_sampled_requests_enabled
		cloudwatch_metrics_enabled  = var.waf_cloudwatch_metrics_enabled
		metric_name                 = var.waf_metric_name
	}
	tags = var.tags
}
