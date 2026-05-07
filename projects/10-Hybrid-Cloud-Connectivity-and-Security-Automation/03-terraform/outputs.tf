output "aws_vpc_id" {
	value = module.aws_vpc.vpc_id
}
output "aws_public_subnet_ids" {
	value = module.aws_vpc.public_subnet_ids
}
output "aws_private_subnet_ids" {
	value = module.aws_vpc.private_subnet_ids
}
output "onprem_vpc_id" {
	value = module.onprem_vpc.vpc_id
}
output "onprem_public_subnet_ids" {
	value = module.onprem_vpc.public_subnet_ids
}
output "onprem_private_subnet_ids" {
	value = module.onprem_vpc.private_subnet_ids
}
output "appserver_instance_id" {
	value = module.appserver.instance_id
}
output "routerpc_instance_id" {
	value = module.routerpc.instance_id
}
output "userpc_instance_id" {
	value = module.userpc.instance_id
}
output "prod_hcsa_vpc_sg_id" {
	value = aws_security_group.prod_hcsa_vpc_sg.id
}
output "onprem_hcsa_vpc_sg_id" {
	value = aws_security_group.onprem_hcsa_vpc_sg.id
}
output "prod_hcsa_vpc_rds_sg_id" {
	value = aws_security_group.prod_hcsa_vpc_rds_sg.id
}
output "prod_hcsa_rds_endpoint" {
	value = aws_db_instance.prod_hcsa_rds.endpoint
}
output "prod_hcsa_rds_arn" {
	value = aws_db_instance.prod_hcsa_rds.arn
}
output "prod_hcsa_rds_id" {
	value = aws_db_instance.prod_hcsa_rds.id
}
output "vpn_connection_id" {
	value = aws_vpn_connection.onprem.id
}
output "vpn_gateway_id" {
	value = aws_vpn_gateway.prod_hcsa_vgw.id
}
output "customer_gateway_id" {
	value = aws_customer_gateway.onprem.id
}
output "appserver_iam_role_arn" {
	value = aws_iam_role.appserver.arn
}
output "routerpc_iam_role_arn" {
	value = aws_iam_role.routerpc.arn
}
output "userpc_iam_role_arn" {
	value = aws_iam_role.userpc.arn
}
output "lambda_block_attacker_iam_role_arn" {
	value = aws_iam_role.lambda_block_attacker.arn
}
