# vpc module outputs
output "aws_vpc1" {
  value = module.vpc_aws_vpc1
}

output "aws_vpc2" {
  value = module.vpc_aws_vpc2
}

output "onpremise_vpc" {
  value = module.vpc_as_onpremise
}

output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_route_table_id" {
  description = "Transit Gateway Route Table ID"
  value       = aws_ec2_transit_gateway_route_table.main.id
}

output "transit_gateway_vpc1_attachment_id" {
  description = "Transit Gateway VPC1 attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
}

output "transit_gateway_vpc2_attachment_id" {
  description = "Transit Gateway VPC2 attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
}

output "vpn_connection_id" {
  description = "Site-to-Site VPN connection ID"
  value       = aws_vpn_connection.onpremise_to_tgw.id
}

output "transit_gateway_vpn_attachment_id" {
  description = "Transit Gateway VPN attachment ID"
  value       = aws_vpn_connection.onpremise_to_tgw.transit_gateway_attachment_id
}

output "vpn_tunnel1_address" {
  description = "VPN tunnel 1 outside (AWS endpoint) IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel1_address
}

output "vpn_tunnel1_inside_cidr" {
  description = "VPN tunnel 1 inside CIDR"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel1_inside_cidr
}

output "vpn_tunnel1_cgw_inside_address" {
  description = "VPN tunnel 1 CGW inside IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel1_cgw_inside_address
}

output "vpn_tunnel1_vgw_inside_address" {
  description = "VPN tunnel 1 VGW (AWS) inside IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel1_vgw_inside_address
}

output "vpn_tunnel1_preshared_key" {
  description = "VPN tunnel 1 preshared key (sensitive)"
  sensitive   = true
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel1_preshared_key
}

output "vpn_tunnel2_address" {
  description = "VPN tunnel 2 outside (AWS endpoint) IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel2_address
}

output "vpn_tunnel2_inside_cidr" {
  description = "VPN tunnel 2 inside CIDR"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel2_inside_cidr
}

output "vpn_tunnel2_cgw_inside_address" {
  description = "VPN tunnel 2 CGW inside IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel2_cgw_inside_address
}

output "vpn_tunnel2_vgw_inside_address" {
  description = "VPN tunnel 2 VGW (AWS) inside IP"
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel2_vgw_inside_address
}

output "vpn_tunnel2_preshared_key" {
  description = "VPN tunnel 2 preshared key (sensitive)"
  sensitive   = true
  value       = aws_vpn_connection.onpremise_to_tgw.tunnel2_preshared_key
}
