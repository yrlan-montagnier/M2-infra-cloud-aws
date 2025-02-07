provider "aws" {
  profile = "formation-infra-cloud"
  region  = "eu-north-1"

  default_tags {
    tags = {
      Owner = local.user # à remplacer par votre utilisateur AWS
    }
  }
}
