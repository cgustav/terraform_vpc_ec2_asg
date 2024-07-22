variable "buckets" {
  description = "List of bucket configurations."
  type = list(object({
    name       = string
    bucket_acl = string
    policy     = string
    versioning = bool
    # logging        = object({
    #   target_bucket = string
    #   target_prefix = string
    # })
    cors_rules = list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = list(string)
      max_age_seconds = number
    }))
  }))
  default = []
}
