resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_1_subnet_cidr
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-sub" }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block              = var.public_2_subnet_cidr
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-2" }
}



# 2. インターネットゲートウェイの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}



# 3. ルートテーブルの作成
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "portfolio-public-rt"
  }
}

# 4. サブネットとルートテーブルの紐付け
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}
