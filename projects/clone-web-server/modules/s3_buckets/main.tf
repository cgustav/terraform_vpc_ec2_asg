resource "aws_s3_bucket" "website_static_files" {
  bucket = var.bucket_name
  # region = "us-east-1"

  tags = {
    Name        = "PracticeStaticFilesBucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_static_files.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Principal: "*",
        Action: [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:PutLifecycleConfiguration",
          "s3:GetBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:PutObject",
        ],
        Resource: [
          "${aws_s3_bucket.website_static_files.arn}",
          "${aws_s3_bucket.website_static_files.arn}/*"
        ]
      },
      {
        Effect: "Allow",
        Principal: "*",
        Action: "s3:DeleteBucket",
        Resource: "${aws_s3_bucket.website_static_files.arn}"
      }
      # {
      #   Effect    = "Allow",
      #   Principal = {"AWS": [var.ec2_role_arn]},
      #   Action    = "s3:GetObject",
      #   Resource  = ["${aws_s3_bucket.website_static_files.arn}","${aws_s3_bucket.website_static_files.arn}/*"]
      # },
      # {
      #   Effect    = "Deny",
      #   Principal = "*",
      #   Action    = "s3:*",
      #   Resource  = ["${aws_s3_bucket.website_static_files.arn}","${aws_s3_bucket.website_static_files.arn}/*"],
      #   Condition = {
      #     StringNotEquals = {
      #       "aws:PrincipalArn": [var.ec2_role_arn]
      #     }
      #   }
      # }
    ]
  })
}

# v2
locals {
  all_files = merge([
    for path in var.paths_to_static_files : {
      for file in fileset(path, "**/*") : "${path}/${file}" => {
        path = path
        file = file
      }
    }
  ]...)
}

resource "aws_s3_bucket_object" "static_files" {
  for_each = local.all_files

  bucket = aws_s3_bucket.website_static_files.id
  key    = replace(each.key, each.value.path, "")  # Elimina el path del directorio para preservar la estructura
  source = each.key
  acl    = "private"
}


