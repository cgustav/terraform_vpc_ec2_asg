output "access_key" {
  value     = aws_iam_access_key.user_key.id
  sensitive = true
}

output "secret_key" {
  value     = aws_iam_access_key.user_key.secret
  sensitive = true
}
