# Ce fichier contient la configuration Terraform pour créer des tables de routage pour les sous-réseaux publics et privés.
# Les sous-réseaux publics sont associés à une table de routage qui redirige tout le trafic sortant vers une passerelle internet.
# Les sous-réseaux privés sont associés à une table de routage qui redirige tout le trafic sortant vers une NAT Gateway.

# Créer une table de routage pour les sous-réseaux publics
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-public-rtb"
  }
}

# Associer la table de routage publique avec les sous-réseaux publics
resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Créer une table de routage pour chaque sous-réseaux privés
resource "aws_route_table" "private" {
  for_each = local.private_subnet

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                   # Tout le trafic sortant
    nat_gateway_id = aws_nat_gateway.public_nat.id # Utilise la NAT Gateway
  }

  tags = {
    Name = "${local.name}-private-rtb-${each.value.az}"
  }
}

# Associer la table de routage privée avec chaque sous-réseaux privés
resource "aws_route_table_association" "private" {
  for_each       = local.private_subnet
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}