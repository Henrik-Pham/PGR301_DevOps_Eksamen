# variables.tf

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 bucket name for storing images"
  default     = "pgr301-couch-explorers"
}

variable "prefix" {
  description = "Prefix for naming resources"
  default     = "ka37"
}
