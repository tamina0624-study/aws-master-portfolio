# security_group module outputs
output "ec2_web_sg_id" {
	value = aws_security_group.ec2_web.id
}
output "alb_sg_id" {
	value = aws_security_group.alb.id
}
