output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.image_processing_lambda.arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.image_generation_queue.id
}

output "bucket_name" {
  description = "Name of the S3 bucket for images"
  value       = data.aws_s3_bucket.images_bucket.bucket
}
