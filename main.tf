provider "aws" {
  region     = "eu-north-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

data "aws_s3_bucket" "existing_bucket" {
  bucket = "myawsbucket061100"
}

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

data "aws_s3_bucket" "bucket" {
  bucket = "myawsbucket061100"
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = data.aws_s3_bucket.bucket.id

  block_public_acls   = false
  block_public_policy = false
}



resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.existing_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin access identity for my bucket"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.existing_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = data.archive_file.lambda_zip.output_path
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "my_api_gateway"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Placeholder for EC2 instance data
resource "aws_instance" "example" {
  ami           = "ami-075449515af5df0d1" # Replace with your AMI ID
  instance_type = "t3.micro" # Replace with your instance type

  tags = {
    Name = "Mein Webserver061100"
  }
}

# Placeholder for S3 bucket data
resource "aws_s3_bucket" "new_bucket" {
  bucket = "myawsbucket061100" # Replace with your bucket name

  tags = {
    Name = "none"
  }
}
