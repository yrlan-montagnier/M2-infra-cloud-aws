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
  count          = length(local.public_subnets_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(local.private_subnets_cidrs)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-private-rtb-${local.azs[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}