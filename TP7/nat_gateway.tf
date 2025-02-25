# Création d'une NAT Gateway pour permettre aux instances privées (nextcloud dans ce cas) d'accéder à internet
# Elle est attachée à un subnet public
# Elle nécessite une EIP
# C'est la route par défaut des instances privées

resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.nat_eip.id         # Associer l'EIP créée
  subnet_id     = aws_subnet.public["a"].id  # Remplace par ton subnet public
  depends_on    = [aws_internet_gateway.igw] # S'assurer que l'IGW est actif

  tags = {
    Name = "${local.name}-NATGateway"
  }
}
