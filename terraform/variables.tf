variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for naming resources"
  default     = "ka37"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  default     = "pgr301-couch-explorers" # Set this to your bucket name
}
