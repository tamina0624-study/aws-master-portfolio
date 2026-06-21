# Customer Gateway リソース定義
resource "aws_customer_gateway" "onpremise" {
  provider   = aws.tokyo
  ip_address = aws_eip.onprem_router_eip.public_ip
  bgp_asn    = var.customer_gateway_bgp_asn
  type       = "ipsec.1"

  tags = {
    Name = var.customer_gateway_name
  }
}
