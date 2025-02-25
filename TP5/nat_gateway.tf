resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.nat_eip.id         # Associer l'EIP créée
  subnet_id     = aws_subnet.public[0].id    # Remplace par ton subnet public
  depends_on    = [aws_internet_gateway.igw] # S'assurer que l'IGW est actif

  tags = {
    Name = "${local.name}-NAT-Gateway"
  }
}
