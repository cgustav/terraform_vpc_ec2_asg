variable "web_security_group_id" {
  description = "ID of the security group for the EC2 Services"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "ID of the public subnets of the VPC"
  type        = list(string)
}


variable "private_subnet_ids" {
  description = "ID of the private subnets of the VPC"
  type        = list(string)
}
