variable "aws_region" {
  type        = string
  description = "AWS region for S3"
  default     = "ap-southeast-1"
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for the S3 lakehouse bucket"
  default     = "lakehouse-data-store"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake Account Identifier (e.g., xy12345 or org-account)"
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake Admin Username"
}

variable "snowflake_password" {
  type        = string
  description = "Snowflake Password"
  sensitive   = true
}