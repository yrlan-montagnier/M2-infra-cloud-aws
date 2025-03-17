# Ce fichier contient la définition de la ressource aws_ami qui permet de récupérer l'AMI la plus récente correspondant à un pattern donné
# Cette ressource est définie dans un bloc data
data "aws_ami" "nextcloud" {
  most_recent = true
  owners      = ["self"]

  # Filtre pour récupérer l'AMI la plus récente correspondant au pattern "ymontagnier-*-nextcloud-*"
  filter {
    name   = "name"
    values = ["${local.user}-ami-nextcloud*"]
  }

  # Filtre pour récupérer une AMI disponible
  filter {
    name   = "state"
    values = ["available"]
  }
}

output "ami_id" {
  value = data.aws_ami.nextcloud.id
}

output "ami_name" {
  value = data.aws_ami.nextcloud.name
}