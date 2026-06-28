# ec2 module outputs
output "instance_id" {
  value = aws_instance.web.id
}
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "ssm_role_name" {
  value = var.ec2_ssm_role_name
}

output "ssm_instance_profile_name" {
  value = coalesce(var.iam_instance_profile, var.ec2_ssm_instance_profile_name)
}
