resource "aws_db_instance" "this" {
  identifier                  = var.db_instance_identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  multi_az                    = var.multi_az
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  backup_retention_period     = var.backup_retention_period
  publicly_accessible         = var.publicly_accessible
  username                    = var.master_username
  manage_master_user_password = var.manage_master_user_password
  skip_final_snapshot         = var.skip_final_snapshot
  deletion_protection         = var.deletion_protection

  tags = var.tags
}
