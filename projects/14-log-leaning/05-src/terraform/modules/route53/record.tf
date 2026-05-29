# Route53レコードリソース定義
resource "aws_route53_record" "alb_alias" {
	zone_id = aws_route53_zone.public.zone_id
	name    = var.record_name
	type    = "A"
	alias {
		name                   = var.alb_dns_name
		zone_id                = var.alb_zone_id
		evaluate_target_health = var.evaluate_target_health
	}
	# aliasレコードではttl/commentは指定不可
}
