# Cette ressource permet de créer une adresse IP élastique pour le NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Public NAT EIP"
  }
}
