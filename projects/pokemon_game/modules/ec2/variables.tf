# variable "web_security_group_id" {
#   description = "ID of the security group for the EC2 Services"
#   type        = string
# }

# variable "target_group_arn" {
#   description = "ARN of the target group"
#   type        = string
# }


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

# variable "public_subnet_ids" {
#   description = "ID of the public subnets of the VPC"
#   type        = list(string)
# }


# variable "private_subnet_ids" {
#   description = "ID of the private subnets of the VPC"
#   type        = list(string)
# }
