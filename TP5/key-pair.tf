resource "aws_key_pair" "bastion" {
  key_name   = "${local.name}-bastion-key"
  public_key = file("./ssh/bastion.pub")

  tags = {
    Name = "${local.name}-bastion-key"
  }
}

resource "aws_key_pair" "nextcloud" {
  key_name   = "${local.name}-nextcloud-key"
  public_key = file("./ssh/nextcloud.pub")

  tags = {
    Name = "${local.name}-nextcloud-key"
  }
}