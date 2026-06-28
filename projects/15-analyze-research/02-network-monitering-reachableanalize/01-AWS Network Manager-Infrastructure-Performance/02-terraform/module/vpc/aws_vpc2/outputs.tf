# vpc module outputs
output "vpc_id" {
  value = aws_vpc.aws_vpc2.id
}

output "default_security_group_id" {
  value = aws_vpc.aws_vpc2.default_security_group_id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
  value = aws_subnet.private_2.id
}
