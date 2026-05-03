# ==========================================
# AWS側 VPNエンドポイント設定 (vpn_aws.tf)
# ==========================================

# オンプレ側ルーター用の固定パブリックIP (Elastic IP)
resource "aws_eip" "onprem_router_eip" {
  domain = "vpc"
  tags = { Name = "OnPrem-Router-EIP" }
}

# 1. Virtual Private Gateway (VGW)
resource "aws_vpn_gateway" "vgw" {
  # 既存のVPC IDを参照してVGWをアタッチ
  vpc_id = data.terraform_remote_state.basic_infra.outputs.vpc_id

  amazon_side_asn = var.aws_bgp_asn
  tags = { Name = "AWS-VGW" }
}

# ★実務テクニック: 既存のルートテーブルに対して、VGWからのルート伝播を有効化する
resource "aws_vpn_gateway_route_propagation" "vgw_route" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = data.aws_route_table.aws_public_rt.id
}

# 2. Customer Gateway (CGW)
resource "aws_customer_gateway" "cgw" {
  ip_address = aws_eip.onprem_router_eip.public_ip
  bgp_asn    = var.onprem_bgp_asn
  type       = "ipsec.1"
  tags = { Name = "OnPrem-CGW" }
}

# 3. Site-to-Site VPN Connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = false
  tags = { Name = "AWS-Site-to-Site-VPN" }
}
