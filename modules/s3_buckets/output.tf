output "s3_bucket_name" {
  value = aws_s3_bucket.website_static_files.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.website_static_files.arn
}
