# インターネットゲートウェイリソース定義
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.as_onpremise_vpc.id
  tags = {
    Name = var.igw_name
  }
}
