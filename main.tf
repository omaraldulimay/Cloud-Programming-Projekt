# Konfiguration des AWS Providers
provider "aws" {
  region     = "eu-north-1"
  access_key = "AKIAZPPF7WBPYSUH7PTO"
  secret_key = "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"
}

# Datenquelle für bestehenden S3-Bucket
data "aws_s3_bucket" "existing_bucket" {
  bucket = "myawsbucket061100"
}

# IAM-Policydokument für S3-Bucket
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.existing_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Datenquelle für S3-Bucket
data "aws_s3_bucket" "bucket" {
  bucket = "myawsbucket061100"
}

# S3-Bucket
resource "aws_s3_bucket" "new_bucket" {
  bucket = "myawsbucket061100" # Ersetzen Sie dies durch Ihren Bucket-Namen

  tags = {
    Name = "none"
  }
}

# Konfiguration für öffentlichen Zugriff auf S3-Bucket blockieren
resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = data.aws_s3_bucket.bucket.id

  block_public_acls   = false
  block_public_policy = false
}

# S3-Bucket-Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.existing_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin access identity for my bucket"
}

# IAM-Policy für CloudFront-Zugriff
resource "aws_iam_policy" "cloudfront_access_policy" {
  name        = "cloudfront-access-policy"
  description = "Policy to allow access to CloudFront Origin Access Identity"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:GetCloudFrontOriginAccessIdentity",
        "cloudfront:ListCloudFrontOriginAccessIdentities",
        "cloudfront:CreateCloudFrontOriginAccessIdentity"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# IAM-Rolle für CloudFront-Zugriff
resource "aws_iam_role" "cloudfront_access_role" {
  name = "cloudfront_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Anfügen der IAM-Policy an die CloudFront-Zugriffsrolle
resource "aws_iam_role_policy_attachment" "cloudfront_access_policy_attachment" {
  role       = aws_iam_role.cloudfront_access_role.name
  policy_arn = aws_iam_policy.cloudfront_access_policy.arn
}

# CloudFront-Distribution für S3-Bucket
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "myawsbucket061100.s3.amazonaws.com" 
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/E3AFN5HFN77JOC"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 bucket distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# EC2-Instanz
resource "aws_instance" "example" {
  ami           = "ami-075449515af5df0d1" # Ersetzen Sie dies durch Ihre AMI-ID
  instance_type = "t3.micro" # Ersetzen Sie dies durch Ihren Instanztyp

  tags = {
    Name = "Mein Webserver061100"
  }
}


