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
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

# Autoriser le trafic HTTPS depuis l'ALB
resource "aws_vpc_security_group_ingress_rule" "allow_https_from_alb_to_nextcloud" {
  security_group_id = aws_security_group.nextcloud_sg.id

  # Autoriser le trafic HTTPS depuis le security group de l'ALB
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

# Autoriser tout le trafic sortant
resource "aws_vpc_security_group_egress_rule" "allow_all_from_nextcloud" {
  security_group_id = aws_security_group.nextcloud_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# -----------------------------------------------------------------------------
# EFS
# -----------------------------------------------------------------------------

# Créer un security group pour l'EFS
resource "aws_security_group" "efs_sg" {
  name        = "${local.name}-efs-sg"
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
  description = "RDS Nextcloud"
  vpc_id      = aws_vpc.main.id

  # Autoriser le trafic MySQL depuis le security group de Nextcloud
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.nextcloud_sg.id]
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------------------------------------------------------
# ALB - Amazon Load Balancer
# -----------------------------------------------------------------------------

# Groupe de sécurité pour l'ALB
resource "aws_security_group" "alb" {
  name   = "nextcloud-alb-sg"
  vpc_id = aws_vpc.main.id

  # Autoriser HTTP/HTTPS depuis les IP de l'entreprise
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["176.138.11.81/32"] # Remplace par l'IP de ton entreprise
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Remplace par l'IP de ton entreprise
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

