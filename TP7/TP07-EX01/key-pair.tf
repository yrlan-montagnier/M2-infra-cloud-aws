# Cette configuration Terraform crée deux paires de clés SSH pour les instances EC2.

# bastion : clé SSH pour l'instance bastion
resource "aws_key_pair" "bastion" {
  key_name   = "${local.name}-bastion-key"
  public_key = file("./ssh/bastion.pub")

  tags = {
    Name = "${local.name}-bastion-key"
  }
}

# nextcloud : clé SSH pour l'instance Nextcloud
resource "aws_key_pair" "nextcloud" {
  key_name   = "${local.name}-nextcloud-key"
  public_key = file("./ssh/nextcloud.pub")

  tags = {
    Name = "${local.name}-nextcloud-key"
  }
}