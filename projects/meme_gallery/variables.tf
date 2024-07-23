
variable "aws_region" {
  description = "AWS default region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
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

variable "ssl_certificate_arn" {
  description = "ACM ARN of the main SSL Cetificate"
  type        = string
}

# variables.tf

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "rds_buffer_pool_size" {
  description = "Buffer size for the RDS instance pool of connections (in bytes, default 128Mb)"
  type        = string
  default     = "134217728"
}

variable "rds_max_connections" {
  description = "Maximum connections for the RDS instance connection pool size"
  type        = number
  default     = 100
}

variable "rds_storage_type" {
  description = "The storage type."
  type        = string
  default     = "gp2"
}

variable "rds_engine" {
  description = "The database engine."
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The database engine version."
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "The name of the database."
  type        = string
  default     = "mydb"
}

variable "rds_username" {
  description = "The username for the database."
  type        = string
  default     = "admin"
}

variable "rds_password" {
  description = "The password for the database."
  type        = string
  default     = "password"
  sensitive   = true
}

variable "rds_parameter_group_name" {
  description = "The name of the DB parameter group."
  type        = string
  default     = "default.mysql8.0"
}

variable "rds_init_script" {
  description = "Database initialization script."
  type        = string
  default     = ""
}

variable "environment" {
  description = "The environment of the deployment."
  type        = string
}

variable "project" {
  description = "The name of the project."
  type        = string
}

variable "public_assets_bucket_manager_username" {
  description = "IAM Username of public access bucket manager (with permissions to upload images)."
  type        = string
}

variable "public_assets_bucket_name" {
  description = "The name of accesible bucket to display images and other assets."
  type        = string
}

