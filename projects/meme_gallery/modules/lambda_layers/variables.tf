variable "layers_spec" {
  description = "List of configured layers."
  type = list(object({
    layer_name  = string
    description = string
    # s3_bucket_id        = string
    # s3_key              = string
    file_name           = string
    source_code_hash    = string
    compatible_runtimes = list(string)
    # depends_on          = list(string)

  }))
  default = []
}
