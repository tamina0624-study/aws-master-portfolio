# ルートテーブルリソース定義
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.analyze_research.id
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}
