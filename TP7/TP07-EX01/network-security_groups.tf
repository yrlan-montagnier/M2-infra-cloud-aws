# -----------------------------------------------------------------------------
# BASTION
# -----------------------------------------------------------------------------

# Créer un security group pour le bastion
resource "aws_security_group" "bastion_sg" {
  name        = "${local.name}-bastion-sg"
  description = "Allow SSH inbound traffic from ynov and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-bastion-sg"
  }
}

# Autoriser le SSH depuis YNOV
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_ynov_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  # YNOV IP
  cidr_ipv4   = "13.38.15.170/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH from YNOV"
  }
}

# Autoriser le SSH depuis Cloud9
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_cloud9_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  # Cloud9 IP
  cidr_ipv4   = "13.38.79.125/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH from Cloud9"
  }
}

# Autoriser le SSH depuis une IP publique
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_maison_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  cidr_ipv4   = "176.138.11.81/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH depuis ma maison"
  }
}

# Autoriser tout le trafic sortant
resource "aws_vpc_security_group_egress_rule" "allow_all_from_bastion" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

  tags = {
    Name = "Allow all outbound traffic"
  }
}

# -----------------------------------------------------------------------------
# NEXTCLOUD
# -----------------------------------------------------------------------------

# Créer un security group pour Nextcloud
resource "aws_security_group" "nextcloud_sg" {
  name        = "${local.name}-nextcloud-sg"
  description = "Allow SSH inbound traffic from bastion and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-nextcloud-sg"
  }
}

# Autoriser le trafic SSH depuis le bastion
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion" {
  security_group_id = aws_security_group.nextcloud_sg.id

  # Autoriser le trafic SSH depuis le security group du bastion
  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "Allow SSH from Bastion"
  }
}

# Autoriser le trafic HTTP depuis l'ALB
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_alb_to_nextcloud" {
  security_group_id = aws_security_group.nextcloud_sg.id

  # Autoriser le trafic HTTP depuis le security group de l'ALB
  referenced_security_group_id = aws_security_group.nextcloud-alb-sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80

  tags = {
    Name = "Allow HTTP from ALB"
  }
}

# Autoriser tout le trafic sortant
resource "aws_vpc_security_group_egress_rule" "allow_all_from_nextcloud" {
  security_group_id = aws_security_group.nextcloud_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports

  tags = {
    Name = "Allow all outbound traffic"
  }
}

# -----------------------------------------------------------------------------
# EFS
# -----------------------------------------------------------------------------

# Créer un security group pour l'EFS
resource "aws_security_group" "efs_sg" {
  name        = "${local.name}-nextcloud-efs-sg"
  description = "Security group for Nextcloud EFS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-nextcloud-efs-sg"
  }
}

# Autoriser uniquement Nextcloud à accéder à EFS sur le port 2049
resource "aws_vpc_security_group_ingress_rule" "allow_nfs_from_nextcloud" {
  security_group_id = aws_security_group.efs_sg.id

  # Autoriser le trafic NFS/EFS depuis le security group de Nextcloud
  referenced_security_group_id = aws_security_group.nextcloud_sg.id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049

  tags = {
    Name = "Allow NFS/EFS access from Nextcloud SG"
  }
}

# -----------------------------------------------------------------------------
# NextCloud_DB - RDS
# -----------------------------------------------------------------------------

# Créer un security group pour la base de données RDS
resource "aws_security_group" "nextcloud_db_sg" {
  name        = "${local.name}-nextcloud-db-sg"
  description = "Security group for Nextcloud RDS"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-nextcloud-db-sg"
  }
}

# Autoriser uniquement Nextcloud à accéder à MySQL sur le port 3306
resource "aws_vpc_security_group_ingress_rule" "allow_mysql_from_nextcloud" {
  security_group_id = aws_security_group.nextcloud_db_sg.id

  # Autoriser le trafic MySQL depuis le security group de Nextcloud
  referenced_security_group_id = aws_security_group.nextcloud_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306

  tags = {
    Name = "Allow MySQL access from Nextcloud SG"
  }
}

# -----------------------------------------------------------------------------
# ALB - Amazon Load Balancer
# -----------------------------------------------------------------------------

# Créer un security group pour le load balancer ALB 
resource "aws_security_group" "nextcloud-alb-sg" {
  name        = "${local.name}-nextcloud-alb-sg"
  description = "Security group for Nextcloud ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-nextcloud-alb-sg"
  }
}

# Autoriser le trafic HTTP depuis l'IP de l'entreprise/maison
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_maison_to_alb" {
  security_group_id = aws_security_group.nextcloud-alb-sg.id

  cidr_ipv4   = "195.7.117.146/32"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

  tags = {
    Name = "Autoriser l'accès à NextCloud depuis ma maison"
  }
}

# Autoriser le trafic HTTP depuis le security group de Nextcloud
resource "aws_vpc_security_group_ingress_rule" "allow_http_from_nextcloud_to_alb" {
  security_group_id = aws_security_group.nextcloud-alb-sg.id

  # Autoriser le trafic HTTP depuis le security group de Nextcloud
  referenced_security_group_id = aws_security_group.nextcloud_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80

  tags = {
    Name = "Allow HTTP access from Nextcloud SG"
  }
}
