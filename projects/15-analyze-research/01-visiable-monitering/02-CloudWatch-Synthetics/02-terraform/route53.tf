data "aws_route53_zone" "log_learning" {
  name         = "log-learning.com"
  private_zone = false
}

resource "aws_route53_record" "alb_alias" {
  zone_id         = data.aws_route53_zone.log_learning.zone_id
  name            = "www"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
