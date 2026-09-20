variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "isolated_subnet_cidrs" {
  description = "The CIDR blocks for the isolated subnets"
  type        = list(string)

  validation {
    condition     = length(var.isolated_subnet_cidrs) > 0 && length(distinct(var.isolated_subnet_cidrs)) == length(var.isolated_subnet_cidrs)
    error_message = "At least one isolated subnet CIDR is required and CIDR blocks must be unique."
  }
}

variable "azs" {
  description = "The availability zones to use for the subnets"
  type        = list(string)
}

variable "alb_name" {
  description = "Base name for the ALB and related resources"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the ALB HTTPS listener"
  type        = string
}

variable "application_port" {
  description = "Port the websocket application listens on and the ALB forwards to"
  type        = number
  default     = 80

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535 && var.application_port == floor(var.application_port)
    error_message = "Application port must be an integer between 1 and 65535."
  }
}

variable "alb_idle_timeout" {
  description = "ALB idle timeout in seconds; long-lived websocket connections need an extended timeout"
  type        = number
  default     = 3600

  validation {
    condition     = var.alb_idle_timeout >= 1 && var.alb_idle_timeout <= 4000 && var.alb_idle_timeout == floor(var.alb_idle_timeout)
    error_message = "ALB idle timeout must be an integer between 1 and 4000 seconds."
  }
}

variable "autoscaling_name" {
  description = "Base name for autoscaling resources"
  type        = string

  validation {
    condition     = length(var.autoscaling_name) <= 40 && can(regex("^[a-zA-Z0-9-]+$", var.autoscaling_name))
    error_message = "Autoscaling name must be <= 40 chars and match [a-zA-Z0-9-]."
  }
}

variable "autoscaling_ami_id" {
  description = "AMI ID for the EC2 instances in the autoscaling group"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.autoscaling_ami_id))
    error_message = "AMI ID must match the ami-<hex> pattern."
  }
}

variable "autoscaling_instance_type" {
  description = "EC2 instance type for the autoscaling group"
  type        = string
  default     = "t3.micro"
}

variable "autoscaling_user_data" {
  description = "Plaintext user data for instance bootstrap. Stored in Terraform state; do not include secrets."
  type        = string
  default     = null
  sensitive   = true
}

variable "autoscaling_min_size" {
  description = "Minimum number of instances in the autoscaling group"
  type        = number
  default     = 2

  validation {
    condition     = var.autoscaling_min_size >= 0 && var.autoscaling_min_size == floor(var.autoscaling_min_size)
    error_message = "Autoscaling minimum size must be a non-negative integer."
  }
}

variable "autoscaling_max_size" {
  description = "Maximum number of instances in the autoscaling group"
  type        = number
  default     = 4

  validation {
    condition     = var.autoscaling_max_size >= var.autoscaling_min_size && var.autoscaling_max_size == floor(var.autoscaling_max_size)
    error_message = "Autoscaling maximum size must be an integer greater than or equal to the minimum size."
  }
}

variable "autoscaling_desired_capacity" {
  description = "Desired number of instances; leave null to let the scaling policy manage capacity"
  type        = number
  default     = null

  validation {
    condition     = var.autoscaling_desired_capacity == null || (var.autoscaling_desired_capacity >= var.autoscaling_min_size && var.autoscaling_desired_capacity <= var.autoscaling_max_size && var.autoscaling_desired_capacity == floor(var.autoscaling_desired_capacity))
    error_message = "Autoscaling desired capacity must be null or an integer between the minimum and maximum size."
  }
}

variable "autoscaling_health_check_grace_period" {
  description = "Health check grace period in seconds for the autoscaling group"
  type        = number
  default     = 300

  validation {
    condition     = var.autoscaling_health_check_grace_period >= 0 && var.autoscaling_health_check_grace_period == floor(var.autoscaling_health_check_grace_period)
    error_message = "Health check grace period must be a non-negative integer."
  }
}

variable "autoscaling_instance_warmup" {
  description = "Estimated instance warmup in seconds for the scaling policy"
  type        = number
  default     = 300

  validation {
    condition     = var.autoscaling_instance_warmup >= 0 && var.autoscaling_instance_warmup == floor(var.autoscaling_instance_warmup)
    error_message = "Instance warmup must be a non-negative integer."
  }
}

variable "autoscaling_cpu_target_value" {
  description = "Target CPU utilization percentage for the target tracking policy"
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_cpu_target_value > 0 && var.autoscaling_cpu_target_value <= 100
    error_message = "CPU target value must be greater than 0 and at most 100."
  }
}

variable "redis_name" {
  description = "Base name for Redis resources"
  type        = string
  default     = "redis"

  validation {
    condition     = length(var.redis_name) <= 40 && can(regex("^[a-zA-Z0-9-]+$", var.redis_name))
    error_message = "Redis name must be <= 40 chars and match [a-zA-Z0-9-]."
  }
}

variable "redis_ami_id" {
  description = "AMI ID for the Redis instance; must be an ARM64 image containing Redis"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.redis_ami_id))
    error_message = "Redis AMI ID must match the ami-<hex> pattern."
  }
}

variable "redis_instance_type" {
  description = "EC2 instance type for the Redis instance"
  type        = string
  default     = "r7g.large"

  validation {
    condition     = length(var.redis_instance_type) > 0
    error_message = "Redis instance type must not be empty."
  }
}

variable "redis_port" {
  description = "Port Redis listens on"
  type        = number
  default     = 6379

  validation {
    condition     = var.redis_port >= 1 && var.redis_port <= 65535 && var.redis_port == floor(var.redis_port)
    error_message = "Redis port must be an integer between 1 and 65535."
  }
}

variable "redis_user_data" {
  description = "Plaintext user data for local-only Redis instance bootstrap. Stored in Terraform state; do not include secrets."
  type        = string
  default     = null
  sensitive   = true
}

variable "redis_enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on the Redis instance"
  type        = bool
  default     = true
}

variable "redis_tags" {
  description = "Tags to apply to Redis resources"
  type        = map(string)
  default     = {}
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