resource "aws_db_instance" "nextcloud_db" {
  identifier             = "${local.name}-nextcloud-rds-instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 10
  username               = "admin"
  password               = "Admin123!"
  db_subnet_group_name   = aws_db_subnet_group.nextcloud_rds_subnet.id
  vpc_security_group_ids = [aws_security_group.nextcloud_db_sg.id]
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
  tags = {
    Name = "${local.name}-nextcloud-rds-instance"
  }
}

resource "aws_db_subnet_group" "nextcloud_rds_subnet" {
  name       = "${local.name}-nextcloud-rds-subnet"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]
  tags = {
    Name = "${local.name}-nextcloud-rds-subnet"
  }
}
