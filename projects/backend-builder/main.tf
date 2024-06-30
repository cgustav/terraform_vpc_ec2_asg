terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

# BUCKET CONFIGURATION
# -------------------------------

# ENABLE THESE FOR ENCRYPTION KEY
# resource "aws_kms_key" "tfstate_bucket_encryption_key" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
#   enable_key_rotation     = true
# }

# resource "aws_kms_alias" "key-alias" {
#   name          = "alias/terraform-bucket-key"
#   target_key_id = aws_kms_key.tfstate_bucket_encryption_key.key_id
# }

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.bucket_name

}

# ENABLE THESE FOR ENCRYPTION KEY
# resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket_encryption_conf" {
#   bucket = aws_s3_bucket.tfstate_bucket.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.tfstate_bucket_encryption_key.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

resource "aws_s3_bucket_versioning" "tfstate_bucket_versioning_conf" {
  bucket = aws_s3_bucket.tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_acl" "tfstate_bucket_acl" {
#   bucket = aws_s3_bucket.tfstate_bucket.id
#   acl    = "private"
# }


resource "aws_s3_bucket_public_access_block" "tfstate_bucket_access_block_conf" {
  bucket = aws_s3_bucket.tfstate_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# BUCKET CONFIGURATION
# -------------------------------


resource "aws_dynamodb_table" "tfstate_dynamodb_table" {
  name           = var.dynamodb_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

