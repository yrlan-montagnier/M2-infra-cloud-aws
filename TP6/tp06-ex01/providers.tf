# Configuration du provider AWS
# Définition du profil et de la région
provider "aws" {
  profile = "formation-infra-cloud" 
  region  = "eu-north-1"            
  
  # Ajout des tags par défaut à tous les éléments créés
  default_tags {
    tags = local.tags 
  }
}