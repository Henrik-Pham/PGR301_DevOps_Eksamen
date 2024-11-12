# Configure Terraform to use an S3 backend for state storage
terraform {
  backend "s3" {
    bucket = "pgr301-couch-explorers"         # Using your existing bucket
    key    = "devops-exam/terraform.tfstate"   # Path for the Terraform state file within the bucket
    region = "eu-west-1"                       # Ensure this matches your AWS region
  }
}

# Configure AWS provider
provider "aws" {
  region = var.aws_region
}

# IAM role for Lambda with S3 access and Bedrock model invocation permissions
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.prefix}_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

# IAM policy to allow access to S3 and invoking the Bedrock model
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.prefix}_lambda_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:GetObject"],
        Resource = "arn:aws:s3:::pgr301-couch-explorers/*"  # Permissions for the entire bucket
      },
      {
        Effect = "Allow",
        Action = "bedrock:InvokeModel",
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}
