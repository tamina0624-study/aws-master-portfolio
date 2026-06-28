resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = var.db_subnet_group_name
  })
}
