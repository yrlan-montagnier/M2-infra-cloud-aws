resource "aws_network_acl" "acl" {
  vpc_id = aws_vpc.main.id

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    rule_no    = 100
    action     = "deny"
    protocol   = "tcp"
    cidr_block = "13.48.4.200/30"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${local.name}-acl"
  }
}

# Association de l'ACL avec les subnets publics
resource "aws_network_acl_association" "public_acl_assoc" {
  for_each       = { for idx, subnet in aws_subnet.public : idx => subnet }
  network_acl_id = aws_network_acl.acl.id
  subnet_id      = each.value.id
}

# Association de l'ACL avec les subnets privés
resource "aws_network_acl_association" "private_acl_assoc" {
  for_each       = { for idx, subnet in aws_subnet.private : idx => subnet }
  network_acl_id = aws_network_acl.acl.id
  subnet_id      = each.value.id
}
