variable "name" {
  description = "Base name for the S3 bucket; combined into <name>-<account-id>-<region>"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 35 && can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.name))
    error_message = "Name must be 3-35 lowercase alphanumeric or hyphen characters, and must start and end with an alphanumeric character."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
