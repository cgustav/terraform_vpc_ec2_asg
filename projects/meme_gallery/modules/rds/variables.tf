# modules/rds/variables.tf

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "buffer_pool_size" {
  description = "Buffer size for the given pool of connections (in bytes, default 128Mb)"
  type        = string
  default     = "134217728"
}

variable "max_connections" {
  description = "Maximum connections for the given db pool size"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "The storage type."
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "The database engine."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "The username for the database."
  type        = string
  default     = "admin"
}

variable "password" {
  description = "The password for the database."
  type        = string
  default     = "password"
  sensitive   = true
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group."
  type        = string
  default     = "default.mysql8.0"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate."
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "The DB subnet group name."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs."
  type        = list(string)
}

variable "init_script" {
  description = "Database initialization script."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
