# modules/ssm/main.tf
resource "aws_ssm_parameter" "db_name" {
  name  = var.db_name_name
  type  = "String"
  value = var.db_name_value
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = var.db_endpoint_name
  type  = "String"
  value = var.db_endpoint_value
}

resource "aws_ssm_parameter" "db_username" {
  name  = var.db_username_name
  type  = "String"
  value = var.db_username_value
}

resource "aws_ssm_parameter" "db_password" {
  name  = var.db_password_name
  type  = "SecureString"
  value = var.db_password_value
}

# Variables for frontend
# ---------------------------
resource "aws_ssm_parameter" "frontend_dns" {
  name  = var.db_password_name
  type  = "String"
  value = var.db_password_value
}

resource "aws_ssm_parameter" "api_address" {
  name  = var.db_password_name
  type  = "String"
  value = var.db_password_value
}

resource "aws_ssm_parameter" "s3_bucket_region" {
  name  = var.s3_bucket_region_name
  type  = "String"
  value = var.s3_bucket_region_value
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  name  = var.s3_bucket_name_name
  type  = "String"
  value = var.s3_bucket_name_value
}

resource "aws_ssm_parameter" "s3_bucket_key_id" {
  name  = var.s3_bucket_key_id_name
  type  = "SecureString"
  value = var.s3_bucket_key_id_value
}

resource "aws_ssm_parameter" "s3_bucket_secret_key" {
  name  = var.s3_bucket_secret_key_name
  type  = "SecureString"
  value = var.s3_bucket_secret_key_value
}
