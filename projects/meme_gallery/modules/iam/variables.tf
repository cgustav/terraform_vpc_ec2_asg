variable "user_name" {
  description = "The name of the IAM user to create"
  type        = string
}

variable "inline_policy" {
  description = "Inline IAM Policy to the given user"
  type        = string
}
