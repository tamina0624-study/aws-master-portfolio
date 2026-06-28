# locals.tf
# VPN接続はリソース生成後にのみ値が確定するため、
# variable の default では参照できない。
# templatefile の展開はここで行い、instance.tf は local.user_data_router を参照する。

locals {
  user_data_router = templatefile("${path.module}/templates/vpn_setup.sh.tpl", {
    # オンプレミスルーターの EIP（vpc/as_onpremise モジュールの出力経由）
    onprem_public_ip = var.vpc.onpremise_vpc.onprem_router_eip

    # オンプレミス / AWS 側の BGP 設定
    onprem_vpc_cidr = var.onprem_vpc_cidr
    onprem_bgp_asn  = var.onprem_bgp_asn
    aws_bgp_asn     = var.aws_bgp_asn

    # AWS VPC CIDRs（ルーターの静的ルート用）
    aws_vpc1_cidr = var.aws_vpc1_cidr
    aws_vpc2_cidr = var.aws_vpc2_cidr

    # トンネル1 の動的生成情報（vpc module output 経由）
    tun1_outside_ip        = var.vpc.vpn_tunnel1_address
    tun1_inside_cidr_block = var.vpc.vpn_tunnel1_inside_cidr
    tun1_inside_cgw_ip     = var.vpc.vpn_tunnel1_cgw_inside_address
    tun1_inside_vgw_ip     = var.vpc.vpn_tunnel1_vgw_inside_address
    tun1_psk               = var.vpc.vpn_tunnel1_preshared_key

    # トンネル2 の動的生成情報（vpc module output 経由）
    tun2_outside_ip        = var.vpc.vpn_tunnel2_address
    tun2_inside_cidr_block = var.vpc.vpn_tunnel2_inside_cidr
    tun2_inside_cgw_ip     = var.vpc.vpn_tunnel2_cgw_inside_address
    tun2_inside_vgw_ip     = var.vpc.vpn_tunnel2_vgw_inside_address
    tun2_psk               = var.vpc.vpn_tunnel2_preshared_key
  })
}
