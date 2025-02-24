resource "aws_instance" "bastion" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  key_name               = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${local.name}-bastion"
  }
}

resource "aws_instance" "nextcloud" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[1].id     # Changer cette ligne pour changer l'AZ
  key_name               = "${local.name}-nextcloud-key"
  vpc_security_group_ids = [aws_security_group.nextcloud_sg.id]
  # user_data              = file("setup_efs.sh")
  user_data = templatefile("setup_efs.sh", {
    efs_dns = aws_efs_file_system.nextcloud_efs.dns_name
  })

  tags = {
    Name = "${local.name}-nextcloud"
  }
}