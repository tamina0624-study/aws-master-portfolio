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
