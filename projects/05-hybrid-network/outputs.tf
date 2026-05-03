output "tun1_psk" {
  value     = aws_vpn_connection.main.tunnel1_preshared_key
  sensitive = true
}
