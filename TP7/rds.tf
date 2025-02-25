# Ce fichier contient la configuration Terraform pour créer une instance RDS MySQL.
# Cette instance sera utilisée par Nextcloud pour stocker ses données.

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

# Créer un groupe de sous-réseaux pour la base de données RDS
resource "aws_db_subnet_group" "nextcloud_rds_subnet" {
  name       = "${local.name}-nextcloud-rds-subnet"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
  tags = {
    Name = "${local.name}-nextcloud-rds-subnet"
  }
}
