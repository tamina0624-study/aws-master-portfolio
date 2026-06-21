# vpc module outputs
output "vpc_id" {
  value = aws_vpc.analyze_research.id
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


output "igw_id" {
  value = aws_internet_gateway.igw.id
}
output "route_table_id" {
  value = aws_route_table.public.id
}
output "nacl_id" {
  value = aws_network_acl.public.id
}

output "ssm_endpoint_security_group_id" {
  value = aws_security_group.vpce_ssm.id
}

output "ssm_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ssm.id
}

output "ssmmessages_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ssmmessages.id
}

output "ec2messages_vpc_endpoint_id" {
  value = aws_vpc_endpoint.ec2messages.id
}
