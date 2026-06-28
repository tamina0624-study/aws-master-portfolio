# ec2 module outputs
output "instance_id" {
  value = aws_instance.web.id
}
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "ssm_role_name" {
  value = aws_iam_role.ec2_ssm.name
}

output "ssm_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_ssm.name
}
