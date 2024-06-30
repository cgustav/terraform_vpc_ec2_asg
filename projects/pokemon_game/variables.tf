# Input variables for Pokemon Online Game AWS Infrastructure

variable "region" {
  description = "AWS region for deployment"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "db_username" {
  description = "Username for the MySQL database"
  type        = string
}

variable "db_password" {
  description = "Password for the MySQL database"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name for the Route 53 zone"
  type        = string
}

variable "subdomain" {
  description = "The subdomain to create the record for"
  type        = string
  default     = "www"
}

variable "create_route53_zone" {
  description = "Whether to create a new Route 53 zone or use an existing one"
  type        = bool
  default     = false
}
