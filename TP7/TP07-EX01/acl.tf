# Description: Configuration de la liste de contrôle d'accès (ACL) pour le VPC

# Création de la liste de contrôle d'accès (ACL)
resource "aws_network_acl" "acl" {
  vpc_id = aws_vpc.main.id

  # Règles de filtrage
  # Règle 100: Autoriser tout le trafic sortant
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Règle 100: Bloquer le trafic SSH depuis la plage d'adresses 13.48.4.200/30 (EC2 instance connect)
  ingress {
    rule_no    = 100
    action     = "deny"
    protocol   = "tcp"
    cidr_block = "13.48.4.200/30"
    from_port  = 22
    to_port    = 22
  }

  # Règle 200: Autoriser tout le reste du trafic 
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${local.name}-acl"
  }
}

# Association de l'ACL avec les subnets publics
resource "aws_network_acl_association" "public_acl_assoc" {
  for_each       = aws_subnet.public
  network_acl_id = aws_network_acl.acl.id
  subnet_id      = each.value.id
}

# Association de l'ACL avec les subnets privés
resource "aws_network_acl_association" "private_acl_assoc" {
  for_each       = aws_subnet.private
  network_acl_id = aws_network_acl.acl.id
  subnet_id      = each.value.id
}

# Sortie: Règles de filtrage en sortie de la liste de contrôle d'accès
output "acl_egress_rules" {
  value = aws_network_acl.acl.egress
}

# Sortie: Règles de filtrage en entrée de la liste de contrôle d'accès
output "acl_ingress_rules" {
  value = aws_network_acl.acl.ingress
}