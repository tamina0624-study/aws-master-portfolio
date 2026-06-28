# ec2 module outputs
output "aws_vpc1" {
  value = module.ec2_aws_vpc1
}

output "aws_vpc2" {
  value = module.ec2_aws_vpc2
}

output "as_onpremise" {
  value = module.ec2_as_onpremise
}

output "common_iam" {
  value = module.common_iam
}
