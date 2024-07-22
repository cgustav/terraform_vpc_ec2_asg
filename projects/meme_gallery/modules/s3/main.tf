resource "aws_s3_bucket" "this" {
  count = length(var.buckets)

  bucket = var.buckets[count.index].name
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = length(aws_s3_bucket.this[*].bucket)

  bucket = aws_s3_bucket.this[count.index].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = length(aws_s3_bucket.this[*].bucket)

  bucket = aws_s3_bucket.this[count.index].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_acl" "this" {
  count  = length(aws_s3_bucket.this[*].bucket)
  bucket = aws_s3_bucket.this[count.index].id


  acl        = var.buckets[count.index].bucket_acl
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_versioning" "this" {
  count  = length(aws_s3_bucket.this[*].bucket)
  bucket = aws_s3_bucket.this[count.index].id
  versioning_configuration {
    status = var.buckets[count.index].versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count  = length(aws_s3_bucket.this[*].bucket)
  bucket = aws_s3_bucket.this[count.index].id

  dynamic "cors_rule" {
    for_each = var.buckets[count.index].cors_rules

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}


resource "aws_s3_bucket_policy" "this" {
  count = length(aws_s3_bucket.this[*].bucket)

  bucket = aws_s3_bucket.this[count.index].id
  policy = var.buckets[count.index].policy

  depends_on = [aws_s3_bucket_public_access_block.this]
}
