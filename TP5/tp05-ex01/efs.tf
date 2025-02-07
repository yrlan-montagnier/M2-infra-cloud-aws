resource "aws_efs_file_system" "nextcloud_efs" {
  creation_token   = "nextcloud-efs-token"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags = {
    Name = "Nextcloud EFS"
  }
}

resource "aws_efs_mount_target" "nextcloud_efs_target_a" {
  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = aws_subnet.private[0].id
  security_groups = [aws_security_group.nextcloud_sg.id]
}

resource "aws_efs_mount_target" "nextcloud_efs_target_b" {
  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = aws_subnet.private[1].id
  security_groups = [aws_security_group.nextcloud_sg.id]
}

resource "aws_efs_mount_target" "nextcloud_efs_target_c" {
  file_system_id  = aws_efs_file_system.nextcloud_efs.id
  subnet_id       = aws_subnet.private[2].id
  security_groups = [aws_security_group.nextcloud_sg.id]
}