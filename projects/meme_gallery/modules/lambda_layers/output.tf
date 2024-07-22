output "layer_arns" {
  value = aws_lambda_layer_version.this[*].arn
}