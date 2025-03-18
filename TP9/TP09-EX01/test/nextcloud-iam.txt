resource "aws_iam_role" "nextcloud_role" {
  name = "${local.name}-nextcloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "nextcloud_role_policy" {
  name   = "NextcloudS3AccessPolicy"
  role   = aws_iam_role.nextcloud_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_bucket.id}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "nextcloud_instance_profile" {
  name = "${local.name}-nextcloud"
  role = aws_iam_role.nextcloud_role.name
}
