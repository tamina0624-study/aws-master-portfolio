# ==========================================
# オンプレミス側 VPNルーター (router_onprem.tf)
# ==========================================


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu の提供元)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "onprem_router" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = "portfolio-key"
  subnet_id     = aws_subnet.onprem_public_subnet.id

  vpc_security_group_ids = [aws_security_group.onprem_router_sg.id]

  # ★超重要ポイント：ルーターとしてパケットを転送するため
  source_dest_check = false
  
  # ★修正ポイント：user_dataを一つに統合
  # テンプレートファイル（vpn_setup.sh.tpl）の中で、インストールコマンドも含めるようにします
  user_data = templatefile("${path.module}/templates/vpn_setup.sh.tpl", {
    onprem_public_ip   = aws_eip.onprem_router_eip.public_ip
    onprem_vpc_cidr    = var.onprem_vpc_cidr
    onprem_bgp_asn     = var.onprem_bgp_asn
    aws_bgp_asn        = var.aws_bgp_asn
    
    # トンネル1の動的生成情報
    tun1_outside_ip    = aws_vpn_connection.main.tunnel1_address
    tun1_inside_cidr_block = aws_vpn_connection.main.tunnel1_inside_cidr
    tun1_inside_cgw_ip = aws_vpn_connection.main.tunnel1_cgw_inside_address
    tun1_inside_vgw_ip = aws_vpn_connection.main.tunnel1_vgw_inside_address
    tun1_psk           = aws_vpn_connection.main.tunnel1_preshared_key
    
    # トンネル2の動的生成情報
    tun2_outside_ip    = aws_vpn_connection.main.tunnel2_address
    tun2_inside_cidr_block = aws_vpn_connection.main.tunnel2_inside_cidr
    tun2_inside_cgw_ip = aws_vpn_connection.main.tunnel2_cgw_inside_address
    tun2_inside_vgw_ip = aws_vpn_connection.main.tunnel2_vgw_inside_address
    tun2_psk           = aws_vpn_connection.main.tunnel2_preshared_key
  })

  tags = { Name = "OnPrem-VPN-Router" }
}


resource "aws_eip_association" "onprem_router_eip_assoc" {
  instance_id   = aws_instance.onprem_router.id
  allocation_id = aws_eip.onprem_router_eip.id
}
