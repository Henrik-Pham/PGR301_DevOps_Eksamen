# variables.tf

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix for naming resources"
  default     = "ka37"
}
