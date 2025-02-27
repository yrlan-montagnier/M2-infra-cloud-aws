# Cette configuration crée des sous-réseaux publics et privés dans le VPC.

# Création des sous-réseaux publics
resource "aws_subnet" "public" {
  for_each          = local.public_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  
  map_public_ip_on_launch = true # Permet de mapper une adresse IP publique à chaque instance lancée dans les sous-réseaux publics
  
  tags = {
    Name = "${local.name}-public-${each.value.az}"
  }
}


# Création des sous-réseaux privés
resource "aws_subnet" "private" {
  for_each          = local.private_subnet
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${local.name}-private-${each.value.az}"
  }
}
