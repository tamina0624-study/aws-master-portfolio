# サブネットリソース定義
resource "aws_subnet" "public_1" {
	vpc_id                  = aws_vpc.log_leaning.id
	cidr_block              = var.public_subnet_cidr_1
	availability_zone       = var.az_1
	map_public_ip_on_launch = true
	tags = {
		Name = var.public_subnet_name_1
	}
}

resource "aws_subnet" "public_2" {
	vpc_id                  = aws_vpc.log_leaning.id
	cidr_block              = var.public_subnet_cidr_2
	availability_zone       = var.az_2
	map_public_ip_on_launch = true
	tags = {
		Name = var.public_subnet_name_2
	}
}
