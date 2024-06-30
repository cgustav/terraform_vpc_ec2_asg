variable "vpc_cidr" {
  description = "CIDR of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR belonging to the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR belonging to the private subnets"
  type        = list(string)
}
