# Cette ressource permet de créer une adresse IP élastique pour le NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Public NAT EIP"
  }
}

output "nat_eip" {
  value = aws_eip.nat_eip.public_ip
}

output "nat_eip_id" {
  value = aws_eip.nat_eip.id
}
