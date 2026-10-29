variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}


variable "s3_name" {
  description = "Base name for the S3 bucket; combined into <name>-<account-id>-<region>"
  type        = string
  default     = "redis"

  validation {
    condition     = length(var.s3_name) >= 3 && length(var.s3_name) <= 35 && can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_name))
    error_message = "S3 name must be 3-35 lowercase alphanumeric or hyphen characters, and must start and end with an alphanumeric character."
  }
}

variable "s3_tags" {
  description = "Tags to apply to S3 resources"
  type        = map(string)
  default     = {}
}