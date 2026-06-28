# サブネットリソース定義
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.analyze_research.id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = var.az_1
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_name_1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.analyze_research.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.az_2
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_name_2
  }
}


resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.analyze_research.id
  cidr_block              = var.private_subnet_cidr_1
  availability_zone       = var.az_1
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_name_1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.analyze_research.id
  cidr_block              = var.private_subnet_cidr_2
  availability_zone       = var.az_2
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_name_2
  }
}
