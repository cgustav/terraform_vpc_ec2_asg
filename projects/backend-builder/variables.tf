variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS profile for deployment"
  type        = string
  default     = "default"
}

variable "bucket_name" {
  description = "Bucket name to store terraform backend state"
  type        = string
}

variable "bucket_encryption" {
  description = "Encryption is enabled for current bucket"
  type        = bool
  default     = false
}

variable "bucket_tfstate_object_key" {
  description = "Default object key where tfstate is stored (used only as a reference)"
  type        = string
  default     = "terraform.tfstate"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to store backend state references"
  type        = string
}
