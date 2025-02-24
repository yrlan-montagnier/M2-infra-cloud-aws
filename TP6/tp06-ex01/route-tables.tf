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

resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = { for idx, subnet in local.private_subnets_cidrs : idx => subnet }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                   # Tout le trafic sortant
    nat_gateway_id = aws_nat_gateway.public_nat.id # Utilise la NAT Gateway
  }

  tags = {
    Name = "${local.name}-private-rtb-${local.azs[each.key]}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = { for idx, subnet in local.private_subnets_cidrs : idx => subnet }
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}