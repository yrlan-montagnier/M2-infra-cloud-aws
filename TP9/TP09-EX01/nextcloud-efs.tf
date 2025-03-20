# Créer un EFS pour Nextcloud
resource "aws_efs_file_system" "nextcloud_efs" {
  creation_token   = "${local.name}-nextcloud-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags = {
    Name = "${local.name}-nextcloud-efs"
  }
}

# Afficher et récupérer le DNS name de l'EFS
output "efs_dns_name" {
  value = aws_efs_file_system.nextcloud_efs.dns_name
}

# Créer un mount target pour chaque subnet privé
resource "aws_efs_mount_target" "nextcloud_efs_targets" {
  for_each = aws_subnet.private

  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.efs_sg.id]
}