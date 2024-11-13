terraform {
  required_version = ">= 1.9"
  backend "s3" {
    bucket = "pgr301-2024-terraform-state"
    key    = "infra/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Reference existing S3 bucket
data "aws_s3_bucket" "images_bucket" {
  bucket = "pgr301-couch-explorers"
}

# SQS Queue
resource "aws_sqs_queue" "image_generation_queue" {
  name                      = "${var.prefix}_image_generation_queue"
  message_retention_seconds = 86400
  visibility_timeout_seconds = 60
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect = "Allow",
    }]
  })
}

# IAM Policy for Lambda to Access S3, SQS, Bedrock, and CloudWatch Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.prefix}_lambda_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject"],
        Resource = "${data.aws_s3_bucket.images_bucket.arn}/*"
      },
      {
        Effect = "Allow",
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.image_generation_queue.arn
      },
      {
        Effect = "Allow",
        Action = "bedrock:InvokeModel",
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      },
      {
        Effect = "Allow",
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Function for Image Processing
resource "aws_lambda_function" "image_processing_lambda" {
  function_name = "${var.prefix}_image_processing_lambda"
  filename      = "lambda_sqs.zip"       # Ensure this zip file is in the current directory
  handler       = "lambda_sqs.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 60

  environment {
    variables = {
      BUCKET_NAME = data.aws_s3_bucket.images_bucket.bucket
    }
  }

  source_code_hash = filebase64sha256("lambda_sqs.zip")
}

# Lambda SQS Trigger
resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.image_generation_queue.arn
  function_name    = aws_lambda_function.image_processing_lambda.arn
  batch_size       = 1
}
