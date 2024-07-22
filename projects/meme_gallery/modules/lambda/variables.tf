variable "lambda_functions" {
  description = "List of Lambda function configurations."
  type = list(object({
    function_name         = string
    handler               = string
    runtime               = string
    source_path           = string
    source_code_hash      = string
    environment_variables = map(string)
    subnet_ids            = list(string)
    security_group_ids    = list(string)
    iam_policy            = string
    log_retention_in_days = number
    layers                = list(string)
  }))
}
