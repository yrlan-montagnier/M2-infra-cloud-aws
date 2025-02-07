output "bucket" {
  description = "Bucket name"
  value       = aws_s3_bucket.my_bucket.bucket
}