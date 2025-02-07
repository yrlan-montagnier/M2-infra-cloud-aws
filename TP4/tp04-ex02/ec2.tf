resource "aws_instance" "bastion" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  key_name               = "${local.name}-bastion-key"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${local.name}-bastion"
  }
}

resource "aws_instance" "nextcloud" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  key_name               = "${local.name}-nextcloud-key"
  vpc_security_group_ids = [aws_security_group.nextcloud_sg.id]

  tags = {
    Name = "${local.name}-nextcloud"
  }
}