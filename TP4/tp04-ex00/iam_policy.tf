resource "aws_iam_user_policy" "allow_s3" {
  name = aws_s3_bucket.my_bucket.id
  user = local.user # Remplacer username par votre nom d'utilisateur
  # Suite à venir
  policy = <<-EOF
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": [
          "${aws_s3_bucket.my_bucket.arn}",
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  }
EOF
}