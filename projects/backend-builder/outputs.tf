
output "region" {
  description = "AWS Bucket Region"
  value       = aws_s3_bucket.tfstate_bucket.region
}

output "bucket_name" {
  description = "Created bucket name"
  value       = aws_s3_bucket.tfstate_bucket.bucket
}

output "bucket_arn" {
  description = "Created bucket arn"
  value       = aws_s3_bucket.tfstate_bucket.arn
}

output "bucket_entryption_enabled" {
  description = "Encryption is enabled to current bucket"
  value       = var.bucket_encryption
}

output "bucket_tfstate_object_key" {
  description = "Terraform state object key reference on current bucket"
  value       = var.bucket_tfstate_object_key
}

output "dynamodb_table_name" {
  description = "Created DynamoDB table name"
  value       = aws_dynamodb_table.tfstate_dynamodb_table.name
}

output "dynamodb_table_arn" {
  description = "Created DynamoDB table ARN"
  value       = aws_dynamodb_table.tfstate_dynamodb_table.arn
}
