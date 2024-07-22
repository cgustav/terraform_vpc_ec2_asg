output "lambda_function_names" {
  value = aws_lambda_function.this[*].function_name
}

output "lambda_functions" {
  value = aws_lambda_function.this[*].arn
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this[*].arn
}
