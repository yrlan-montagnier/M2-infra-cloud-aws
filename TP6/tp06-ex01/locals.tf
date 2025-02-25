# Ce fichier contient les variables locales utilisées dans le projet
# Ces variables sont utilisées pour définir des valeurs réutilisables dans le projet
# Elles sont définies une seule fois et peuvent être utilisées dans plusieurs fichiers
# Elles sont définies dans un bloc locals

locals {
  user = "ymontagnier"                # Change this to your own username
  tp   = basename(abspath(path.root)) # Get the name of the current directory
  name = "${local.user}-${local.tp}"  # Concatenate the username and the directory name
  tags = {                            # Define a map of tags to apply to all resources
    Name  = local.name
    Owner = local.user
  }

  vpc_cidr = "10.0.0.0/16" # Définition du CIDR du VPC

  public_subnet = {
    "eu-north-1a" = "10.0.1.0/24"
    "eu-north-1b" = "10.0.2.0/24"
    "eu-north-1c" = "10.0.3.0/24"
  }

  private_subnet = {
    a = {
      az   = "eu-north-1a"
      cidr = "10.0.4.0/24"
    }
    b = {
      az   = "eu-north-1b"
      cidr = "10.0.5.0/24"
    }
    c = {
      az   = "eu-north-1c"
      cidr = "10.0.6.0/24"
    }
  }

  # public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Définition des CIDRs des subnets publics
  # private_subnets_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] # Définition des CIDRs des subnets privés
  # azs                   = ["eu-north-1a", "eu-north-1b", "eu-north-1c"] # Définition des AZs
}