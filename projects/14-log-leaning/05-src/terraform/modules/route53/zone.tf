# Route53ゾーンリソース定義
resource "aws_route53_zone" "public" {
	name    = var.zone_name
	comment = var.zone_comment
}
