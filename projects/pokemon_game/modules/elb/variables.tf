# Variable declarations
variable "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
