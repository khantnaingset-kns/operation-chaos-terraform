variable "name" {
  description = "Base name for autoscaling resources"
  type        = string

  validation {
    condition     = length(var.name) <= 40 && can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must be <= 40 chars and match [a-zA-Z0-9-]."
  }
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances are launched"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the autoscaling group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) > 0 && length(distinct(var.private_subnet_ids)) == length(var.private_subnet_ids)
    error_message = "At least one private subnet ID is required and subnet IDs must be unique."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB allowed to reach the instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group the instances register with"
  type        = string
}

variable "target_group_port" {
  description = "Port on which the application receives traffic"
  type        = number

  validation {
    condition     = var.target_group_port >= 1 && var.target_group_port <= 65535 && var.target_group_port == floor(var.target_group_port)
    error_message = "Target group port must be an integer between 1 and 65535."
  }
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string

  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "AMI ID must match the ami-<hex> pattern."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "user_data" {
  description = "Plaintext user data for instance bootstrap, base64-encoded by the module. Stored in Terraform state; do not include secrets."
  type        = string
  default     = null
  sensitive   = true
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 0 && var.min_size == floor(var.min_size)
    error_message = "Minimum size must be a non-negative integer."
  }
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= var.min_size && var.max_size == floor(var.max_size)
    error_message = "Maximum size must be an integer greater than or equal to the minimum size."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances; leave null to let the scaling policy manage capacity"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity == null || (var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size && var.desired_capacity == floor(var.desired_capacity))
    error_message = "Desired capacity must be null or an integer between the minimum and maximum size."
  }
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.health_check_grace_period >= 0 && var.health_check_grace_period == floor(var.health_check_grace_period)
    error_message = "Health check grace period must be a non-negative integer."
  }
}

variable "instance_warmup" {
  description = "Estimated instance warmup in seconds for the scaling policy"
  type        = number
  default     = 300

  validation {
    condition     = var.instance_warmup >= 0 && var.instance_warmup == floor(var.instance_warmup)
    error_message = "Instance warmup must be a non-negative integer."
  }
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for target tracking"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target value must be greater than 0 and at most 100."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on instances"
  type        = bool
  default     = true
}

variable "disable_scale_in" {
  description = "Disable scale-in for the target tracking policy"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
