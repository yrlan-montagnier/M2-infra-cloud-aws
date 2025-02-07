resource "aws_subnet" "public" {
  count = length(local.public_subnets_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.private_subnets_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${local.name}-private-${local.azs[count.index]}"
  }
}