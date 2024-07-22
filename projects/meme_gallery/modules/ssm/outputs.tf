# modules/ssm/outputs.tf

output "db_endpoint_name" {
  description = "The name of the SSM parameter for the database endpoint."
  value       = aws_ssm_parameter.db_endpoint.name
}

output "db_name_name" {
  description = "The name of the SSM parameter for the database name reference."
  value       = aws_ssm_parameter.db_name.name
}

output "db_username_name" {
  description = "The name of the SSM parameter for the database username."
  value       = aws_ssm_parameter.db_username.name
}

output "db_password_name" {
  description = "The name of the SSM parameter for the database password."
  value       = aws_ssm_parameter.db_password.name
}

output "frontend_dns_name" {
  description = "Frontend public DNS name reference."
  value       = aws_ssm_parameter.frontend_dns.name
}

output "api_address_name" {
  description = "Public API Address name reference."
  value       = aws_ssm_parameter.api_address.name
}

output "s3_bucket_region_name" {
  description = "Reference of public assets bucket region."
  value       = aws_ssm_parameter.s3_bucket_name.name
}

output "s3_bucket_name_name" {
  description = "Reference of public assets bucket name."
  value       = aws_ssm_parameter.s3_bucket_name.name
}

output "s3_bucket_key_id_name" {
  description = "Reference of public assets bucket consumer access key id name."
  value       = aws_ssm_parameter.s3_bucket_key_id.name
}

output "s3_bucket_secret_key_name" {
  description = "Reference of public assets bucket. Consumer's access secret key name."
  value       = aws_ssm_parameter.s3_bucket_secret_key.name
}
