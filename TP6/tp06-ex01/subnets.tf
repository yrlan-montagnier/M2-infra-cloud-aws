# Subnets publics
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

# Subnets privés
resource "aws_subnet" "private" {
  for_each = { for idx, cidr in local.private_subnets_cidrs : idx => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = local.azs[each.key]

  tags = {
    Name = "${local.name}-private-${local.azs[each.key]}"
  }
}
