# main.tf

provider "aws" {
  region = var.aws_region
}

# S3 bucket for storing images
resource "aws_s3_bucket" "images_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

# IAM role for Lambda to allow S3 access and Bedrock model invocation
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}_lambda_exec_role"
  assume_role_policy = jsonencode({
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
  })
}

# IAM policy for accessing S3 and invoking the Bedrock model
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.prefix}_lambda_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.images_bucket.bucket}/*"
      },
      {
        "Effect": "Allow",
        "Action": "bedrock:InvokeModel",
        "Resource": "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

# Output bucket name
output "bucket_name" {
  value = aws_s3_bucket.images_bucket.bucket
}
