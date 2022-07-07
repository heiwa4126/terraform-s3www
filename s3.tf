resource "aws_s3_bucket" "www" {
  bucket = "${local.prefix}www"
}

resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id
  acl    = "private"
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
