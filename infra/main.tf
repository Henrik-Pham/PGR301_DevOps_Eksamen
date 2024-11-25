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

data "aws_s3_bucket" "images_bucket" {
  bucket = "pgr301-couch-explorers"
}

resource "aws_sqs_queue" "image_generation_queue" {
  name                       = "${var.prefix}_image_generation_queue"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 60
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow",
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.prefix}_lambda_policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "${data.aws_s3_bucket.images_bucket.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.image_generation_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = "bedrock:InvokeModel",
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "image_processing_lambda" {
  function_name = "${var.prefix}_image_processing_lambda"
  filename      = "lambda_sqs.zip" 
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

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.image_generation_queue.arn
  function_name    = aws_lambda_function.image_processing_lambda.arn
  batch_size       = 1
}

resource "aws_sns_topic" "sqs_delay_alarm_topic" {
  name = "${var.prefix}_sqs_delay_alarm_topic"
}

resource "aws_sns_topic_subscription" "sqs_delay_email_subscription" {
  topic_arn = aws_sns_topic.sqs_delay_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_approximate_age_alarm" {
  alarm_name          = "${var.prefix}_sqs_approximate_age_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.AgeOfOldestMessage_Alarm

  dimensions = {
    QueueName = aws_sqs_queue.image_generation_queue.name
  }

  alarm_actions = [
    aws_sns_topic.sqs_delay_alarm_topic.arn
  ]
}

