output "role_name" {
  value = aws_iam_role.ec2_ssm.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_ssm.name
}
