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
# jfsec:ignore:aws-s3-no-public-buckets
resource "aws_s3_bucket_public_access_block" "www" {
  depends_on              = [aws_s3_bucket_policy.www]
  bucket                  = aws_s3_bucket.www.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# ACL無効
# ACLを一切使わない。ポリシーのみで制御。最近の流行
resource "aws_s3_bucket_ownership_controls" "www" {
  bucket = aws_s3_bucket.www.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# resource "aws_s3_bucket_acl" "www" {
#   bucket = aws_s3_bucket.www.id
#   acl    = "private"
# }

# block_public_policy=trueなので
# 最初に設定したら後から変更できないことに注意。
# コンソールで一旦「新しいパブリックバケットポリシーまたはアクセスポイントポリシーを介して付与されたバケットとオブジェクトへのパブリックアクセスをブロックする」(長い) のチェックをはずして、
# バケットポリシーを修正した後、チェックをつける必要がある。
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
        "Resource" : "${aws_s3_bucket.www.arn}/*"
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
