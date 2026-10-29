variable "name" {
  description = "Base name for Redis resources"
  type        = string

  validation {
    condition     = length(var.name) <= 40 && can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must be <= 40 chars and match [a-zA-Z0-9-]."
  }
}

variable "vpc_id" {
  description = "VPC ID where the Redis instance is launched"
  type        = string
}

variable "subnet_id" {
  description = "Isolated subnet ID for the Redis instance"
  type        = string
}

variable "client_security_group_id" {
  description = "Security group ID of the clients allowed to reach Redis"
  type        = string
}

variable "route_table_id" {
  description = "ID of the route table for the Redis subnet; the S3 gateway endpoint routes are added to it"
  type        = string

  validation {
    condition     = can(regex("^rtb-[0-9a-f]+$", var.route_table_id))
    error_message = "Route table ID must match the rtb-<hex> pattern."
  }
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the Redis instance accesses through the gateway endpoint"
  type        = string

  validation {
    condition     = can(regex("^arn:[a-z0-9-]+:s3:::[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_arn))
    error_message = "S3 bucket ARN must be a valid bucket ARN such as arn:aws:s3:::bucket-name."
  }
}

variable "ami_id" {
  description = "AMI ID for the Redis instance; must be an ARM64 image containing Redis"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "AMI ID must match the ami-<hex> pattern."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the Redis instance"
  type        = string
  default     = "r7g.large"

  validation {
    condition     = length(var.instance_type) > 0
    error_message = "Instance type must not be empty."
  }
}

variable "port" {
  description = "Port Redis listens on"
  type        = number
  default     = 6379

  validation {
    condition     = var.port >= 1 && var.port <= 65535 && var.port == floor(var.port)
    error_message = "Port must be an integer between 1 and 65535."
  }
}

variable "user_data" {
  description = "Plaintext user data for instance bootstrap; the Redis security group only allows outbound HTTPS to S3 through the gateway endpoint. Stored in Terraform state; do not include secrets."
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on the Redis instance"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
