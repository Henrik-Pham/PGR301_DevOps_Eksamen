# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "eu-west-1" # Make sure this is the correct region
}

variable "prefix" {
  description = "A unique prefix for resource names"
  default     = "ka37" # Use your candidate number or unique identifier
}
