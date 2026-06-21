# Site-to-Site VPN リソース定義
# as_onpremise の Customer Gateway と Transit Gateway を接続

resource "aws_vpn_connection" "onpremise_to_tgw" {
  provider            = aws.tokyo
  customer_gateway_id = module.vpc_as_onpremise.customer_gateway_id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name        = "${var.transit_gateway_name}-vpn-onpremise"
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_to_onpremise" {
  provider                        = aws.tokyo
  destination_cidr_block         = var.vpc_cidr_as_onpremise
  transit_gateway_attachment_id  = aws_vpn_connection.onpremise_to_tgw.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}
