locals {
  user = "ymontagnier"                # Change this to your own username
  tp   = basename(abspath(path.root)) # Get the name of the current directory
  name = "${local.user}-${local.tp}"  # Concatenate the username and the directory name
  tags = {                            # Define a map of tags to apply to all resources
    Name  = local.name
    Owner = local.user
  }

  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  azs                   = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}