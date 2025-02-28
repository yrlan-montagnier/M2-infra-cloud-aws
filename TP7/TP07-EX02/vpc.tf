resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true # Activer les noms de domaine pour les instances EC2 et le système de fichier EFS

  tags = {
    Name = "${local.name}-vpc"
  }
}