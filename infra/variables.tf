variable "prefix" {
  description = "A unique prefix for resource names"
  type        = string
  default     = "ka37"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}
