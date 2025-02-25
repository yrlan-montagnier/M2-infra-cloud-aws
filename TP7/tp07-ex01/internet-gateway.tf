# Cette ressource permet de créer une passerelle internet pour notre VPC
# Elle est nécessaire pour que les instances puissent communiquer avec internet
# Elle est attachée à notre VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name}-igw"
  }
}