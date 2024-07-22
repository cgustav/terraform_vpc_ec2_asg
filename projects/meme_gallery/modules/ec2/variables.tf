variable "server_configs" {
  description = "List of server configurations"
  type = list(object({
    name               = string
    instance_type      = string
    image_id           = string
    security_group_ids = list(string)
    user_data          = string
    desired_capacity   = number
    min_size           = number
    max_size           = number
    target_group_arns  = list(string)
    subnet_ids         = list(string)
  }))
}
