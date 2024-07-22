# modules/ssm/variables.tf


variable "db_name_name" {
  description = "The name of the SSM parameter for the database name reference."
  type        = string
}

variable "db_name_value" {
  description = "The value of the SSM parameter for the database name reference."
  type        = string
}

variable "db_endpoint_name" {
  description = "The name of the SSM parameter for the database endpoint."
  type        = string
}

variable "db_endpoint_value" {
  description = "The value of the SSM parameter for the database endpoint."
  type        = string
}

variable "db_username_name" {
  description = "The name of the SSM parameter for the database username."
  type        = string
}

variable "db_username_value" {
  description = "The value of the SSM parameter for the database username."
  type        = string
}

variable "db_password_name" {
  description = "The name of the SSM parameter for the database password."
  type        = string
}

variable "db_password_value" {
  description = "The value of the SSM parameter for the database password."
  type        = string
}


# Variables for frontend
# ---------------------------


variable "frontend_dns_name" {
  description = "Frontend public DNS name reference."
  type        = string
}

variable "frontend_dns_value" {
  description = "Frontend public DNS value."
  type        = string
}

variable "api_address_name" {
  description = "Public API Address name reference."
  type        = string
}

variable "api_address_value" {
  description = "Public API Address DNS value."
  type        = string
}

variable "s3_bucket_region_name" {
  description = "Reference of public assets bucket region."
  type        = string
}

variable "s3_bucket_region_value" {
  description = "Value of public assets bucket region."
  type        = string
}

variable "s3_bucket_name_name" {
  description = "Reference of public assets bucket name."
  type        = string
}

variable "s3_bucket_name_value" {
  description = "Value of public assets bucket name."
  type        = string
}

variable "s3_bucket_key_id_name" {
  description = "Reference of public assets bucket consumer access key id name."
  type        = string
}

variable "s3_bucket_key_id_value" {
  description = "Value of public assets bucket consumer acess key id."
  type        = string
}

variable "s3_bucket_secret_key_name" {
  description = "Reference of public assets bucket. Consumer's access secret key name."
  type        = string
}

variable "s3_bucket_secret_key_value" {
  description = "Value of public assets bucket. Consumer's access secret key."
  type        = string
}
