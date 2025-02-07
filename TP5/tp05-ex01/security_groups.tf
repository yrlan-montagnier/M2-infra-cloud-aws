# -----------------------------------------------------------------------------
# BASTION
# -----------------------------------------------------------------------------

resource "aws_security_group" "bastion_sg" {
  name        = "${local.name}-bastion-sg"
  description = "Allow SSH inbound traffic from ynov and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-bastion-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_ynov_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  cidr_ipv4   = "13.38.15.170/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH from YNOV"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_cloud9_to_bastion" {
  security_group_id = aws_security_group.bastion_sg.id

  cidr_ipv4   = "13.38.79.125/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

  tags = {
    Name = "Allow SSH from Cloud9"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_from_bastion" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# -----------------------------------------------------------------------------
# NEXTCLOUD
# -----------------------------------------------------------------------------

resource "aws_security_group" "nextcloud_sg" {
  name        = "${local.name}-nextcloud-sg"
  description = "Allow SSH inbound traffic from bastion and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name}-nextcloud-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_bastion" {
  security_group_id = aws_security_group.nextcloud_sg.id

  referenced_security_group_id = aws_security_group.bastion_sg.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22

  tags = {
    Name = "Allow SSH from Bastion"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ECS" {
  security_group_id = aws_security_group.nextcloud_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 2049
  ip_protocol = "tcp"
  to_port     = 2049

  tags = {
    Name = "Allow ECS"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_from_nextcloud" {
  security_group_id = aws_security_group.nextcloud_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

