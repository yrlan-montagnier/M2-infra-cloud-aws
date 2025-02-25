# Ce fichier est un fichier Terraform qui définit les ressources EC2 à créer
# Il crée deux instances EC2, une instance bastion et une instance nextcloud
# L'instance bastion est créée dans un subnet public et l'instance nextcloud dans un subnet privé
# L'instance nextcloud est configurée avec un script de démarrage qui monte un système de fichiers EFS

# Définition de la ressource aws_instance bastion
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

# Définition de la ressource aws_instance nextcloud
resource "aws_instance" "nextcloud" {
  ami                    = "ami-09a9858973b288bdd"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id # Changer cette ligne pour changer l'AZ
  key_name               = aws_key_pair.nextcloud.key_name 
  vpc_security_group_ids = [aws_security_group.nextcloud_sg.id]
  user_data = templatefile("setup_efs.sh", { # Utiliser un script de démarrage pour monter le système de fichiers EFS
    efs_dns = aws_efs_file_system.nextcloud_efs.dns_name # Passer le nom DNS du système de fichiers EFS au script de démarrage
  })

  depends_on = [aws_nat_gateway.public_nat] # Attendre que la gateway NAT soit créée

  tags = {
    Name = "${local.name}-nextcloud"
  }
}