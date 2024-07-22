resource "aws_iam_role" "lambda_exec" {
  count = length(var.lambda_functions)

  name = "${var.lambda_functions[count.index].function_name}_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_policy" "lambda_policy" {
#   count = length(var.lambda_functions)

#   policy = var.lambda_functions[count.index].iam_policy
# }


resource "aws_iam_role_policy" "lambda_exec_policy" {
  count = length(var.lambda_functions)

  name = "${var.lambda_functions[count.index].function_name}_exec_policy"
  role = aws_iam_role.lambda_exec[count.index].id
  #   policy = aws_iam_policy.lambda_policy[count.index].policy
  policy = var.lambda_functions[count.index].iam_policy
}

resource "aws_lambda_function" "this" {
  count = length(var.lambda_functions)

  function_name = var.lambda_functions[count.index].function_name
  handler       = var.lambda_functions[count.index].handler
  runtime       = var.lambda_functions[count.index].runtime
  role          = aws_iam_role.lambda_exec[count.index].arn
  filename      = var.lambda_functions[count.index].source_path

  environment {
    variables = var.lambda_functions[count.index].environment_variables
  }

  vpc_config {
    subnet_ids         = var.lambda_functions[count.index].subnet_ids
    security_group_ids = var.lambda_functions[count.index].security_group_ids
  }

  #   source_code_hash = filebase64sha256(var.lambda_functions[count.index].source_path)
  source_code_hash = var.lambda_functions[count.index].source_code_hash
  layers           = var.lambda_functions[count.index].layers
}

resource "aws_cloudwatch_log_group" "this" {
  count             = length(var.lambda_functions)
  name              = "/aws/lambda/${var.lambda_functions[count.index].function_name}"
  retention_in_days = var.lambda_functions[count.index].log_retention_in_days
}


