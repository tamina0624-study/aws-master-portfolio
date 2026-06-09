# route53 module outputs
output "zone_id" {
  value = aws_route53_zone.public.zone_id
}
