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

variable "notification_email" {
  description = "Email address to receive alarm notifications"
  type        = string
}

variable "AgeOfOldestMessage_Alarm" {
  description = "Threshold in seconds for ApproximateAgeOfOldestMessage"
  type        = number
}