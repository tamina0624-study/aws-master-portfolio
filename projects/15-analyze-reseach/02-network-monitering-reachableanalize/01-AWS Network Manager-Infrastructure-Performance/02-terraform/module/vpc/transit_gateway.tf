# Transit Gateway リソース定義
# aws_vpc1 と aws_vpc2 を Transit Gateway で接続

# Transit Gateway の作成
resource "aws_ec2_transit_gateway" "main" {
  provider                        = aws.tokyo
  description                     = "Transit Gateway for VPC connectivity (aws_vpc1, aws_vpc2)"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name        = var.transit_gateway_name
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

# Transit Gateway ルートテーブルの作成
resource "aws_ec2_transit_gateway_route_table" "main" {
  provider           = aws.tokyo
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name        = "${var.transit_gateway_name}-rtb"
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

# aws_vpc1 を Transit Gateway にアタッチ
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  provider             = aws.tokyo
  transit_gateway_id   = aws_ec2_transit_gateway.main.id
  vpc_id               = module.vpc_aws_vpc1.vpc_id
  subnet_ids           = [module.vpc_aws_vpc1.private_subnet_1_id, module.vpc_aws_vpc1.private_subnet_2_id]
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name        = "${var.transit_gateway_name}-attachment-vpc1"
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

# aws_vpc2 を Transit Gateway にアタッチ
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  provider             = aws.tokyo
  transit_gateway_id   = aws_ec2_transit_gateway.main.id
  vpc_id               = module.vpc_aws_vpc2.vpc_id
  subnet_ids           = [module.vpc_aws_vpc2.private_subnet_1_id, module.vpc_aws_vpc2.private_subnet_2_id]
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name        = "${var.transit_gateway_name}-attachment-vpc2"
    Environment = "Portfolio"
    Project     = "analyze-research"
    ManagedBy   = "Terraform"
  }
}

# aws_vpc1 から aws_vpc2 への ルート設定
resource "aws_ec2_transit_gateway_route" "vpc1_to_vpc2" {
  provider                        = aws.tokyo
  destination_cidr_block          = var.vpc_cidr_aws_vpc2
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.main.id
}

# aws_vpc2 から aws_vpc1 への ルート設定
resource "aws_ec2_transit_gateway_route" "vpc2_to_vpc1" {
  provider                        = aws.tokyo
  destination_cidr_block          = var.vpc_cidr_aws_vpc1
  transit_gateway_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id  = aws_ec2_transit_gateway_route_table.main.id
}
