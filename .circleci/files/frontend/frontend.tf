# Variables
variable "ID" {
  description = "Unique identifier."
  type        = string
}

# Resources
resource "aws_s3_bucket" "WebsiteBucket" {
  bucket = "udapeople-${var.ID}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_policy" "WebsiteBucketPolicy" {
  bucket = aws_s3_bucket.WebsiteBucket.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadForGetBucketObjects",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.WebsiteBucket.id}/*"
      }
    ]
  }
EOF
}

# Outputs
output "WebsiteURL" {
  value       = aws_s3_bucket.WebsiteBucket.website_endpoint
  description = "URL for website hosted on S3"
}