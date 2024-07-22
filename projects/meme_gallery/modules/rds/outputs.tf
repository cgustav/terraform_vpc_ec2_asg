# modules/rds/outputs.tf


output "db_name" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.this.name
}

output "db_instance_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_username" {
  description = "The username for the RDS instance."
  value       = aws_db_instance.this.username
}

output "db_instance_password" {
  description = "The password for the RDS instance."
  value       = var.password
  sensitive   = true
}
