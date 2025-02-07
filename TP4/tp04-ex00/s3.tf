resource "aws_s3_bucket" "my_bucket" {
  bucket_prefix = "${local.user}-" # Remplacer username par votre nom d'utilisateur
  force_destroy = true
}