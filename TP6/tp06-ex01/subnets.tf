# Cette configuration crée des sous-réseaux publics et privés dans une VPC.

# Création des sous-réseaux publics
# vpc_id: ID de la VPC
# cidr_block: On utilise un for_each pour créer un sous-réseau par élément de la liste local.public_subnets_cidrs.
# availability_zone: On utilise la variable local.azs pour déterminer l'AZ de chaque sous-réseau.
# map_public_ip_on_launch: On active l'option map_public_ip_on_launch pour permettre aux instances de recevoir une adresse IP publique.
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in local.public_subnets_cidrs : idx => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.azs[each.key]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-${local.azs[each.key]}"
  }
}

# Création des sous-réseaux privés
# vpc_id: ID de la VPC
# cidr_block: On utilise un for_each pour créer un sous-réseau par élément de la liste local.private_subnets_cidrs.
# availability_zone: On utilise la variable local.azs pour déterminer l'AZ de chaque sous-réseau.
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in local.private_subnets_cidrs : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = local.azs[each.key]

  tags = {
    Name = "${local.name}-private-${local.azs[each.key]}"
  }
}
