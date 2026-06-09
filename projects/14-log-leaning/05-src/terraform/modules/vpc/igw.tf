# インターネットゲートウェイリソース定義
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.log_leaning.id
  tags = {
    Name = var.igw_name
  }
}
