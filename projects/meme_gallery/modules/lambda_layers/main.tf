resource "aws_lambda_layer_version" "this" {
  count = length(var.layers_spec)

  layer_name  = var.layers_spec[count.index].layer_name
  description = var.layers_spec[count.index].description
  #   s3_bucket           = var.layers_spec[count.index].s3_bucket_id
  #   s3_key              = var.layers_spec[count.index].s3_key
  filename            = var.layers_spec[count.index].file_name
  source_code_hash    = var.layers_spec[count.index].source_code_hash
  compatible_runtimes = var.layers_spec[count.index].compatible_runtimes
  #   depends_on          = var.layers_spec[count.index].depends_on

}
