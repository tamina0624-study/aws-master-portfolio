# vpc module outputs
output "vpc_id" {
  value = aws_vpc.as_onpremise_vpc.id
}

output "default_security_group_id" {
  value = aws_vpc.as_onpremise_vpc.default_security_group_id
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

output "onprem_router_eip" {
  value = aws_eip.onprem_router_eip.public_ip
}

output "onprem_router_eip_allocation_id" {
  value = aws_eip.onprem_router_eip.id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.onpremise.id
}
