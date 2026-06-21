# VPCリソース定義
resource "aws_vpc" "as_onpremise_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_eip" "onprem_router_eip" {
  domain = "vpc"
  tags = { Name = "OnPrem-Router-EIP" }
}
