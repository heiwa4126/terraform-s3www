# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "www" {
  bucket = "${local.prefix}www"
}

# 自前のキーにするとお金がちょっとかかるので
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "www" {
  bucket = aws_s3_bucket.www.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# バケットポリシーのみで外部公開にする
# tfsec:ignore:aws-s3-no-public-buckets
resource "aws_s3_bucket_public_access_block" "www" {
  depends_on              = [aws_s3_bucket_policy.www]
  bucket                  = aws_s3_bucket.www.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "www" {
  bucket = aws_s3_bucket.www.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::ota-s3www-www/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  # error_document {
  #   key = "error.html"
  # }
  index_document {
    suffix = "index.html"
  }
}

# resource "aws_s3_object" "index" {
#   key          = "index.html"
#   bucket       = aws_s3_bucket.www.id
#   source       = "contents/index.html"
#   content_type = "text/html"
#   etag         = filemd5("contents/index.html")
#   acl          = "public-read"
# }

# resource "aws_s3_object" "logo" {
#   key          = "imgs/logo1.png"
#   bucket       = aws_s3_bucket.www.id
#   source       = "contents/imgs/logo1.png"
#   content_type = "image/png"
#   etag         = filemd5("contents/imgs/logo1.png")
#   acl          = "public-read"
# }

resource "aws_s3_object" "www" {
  for_each = fileset("${path.root}/contents", "**/*")

  bucket = aws_s3_bucket.www.id
  key    = each.value
  source = "${path.root}/contents/${each.value}"

  etag         = filemd5("${path.root}/contents/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)
  acl          = "public-read"
}

output "s3wwwurl" {
  description = "URL of S3 bucket to hold website content"
  value       = "http://${aws_s3_bucket_website_configuration.www.website_endpoint}/"
}
