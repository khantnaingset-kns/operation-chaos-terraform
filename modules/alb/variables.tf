variable "name" {
  description = "Base name for ALB resources"
  type        = string

  validation {
    condition     = length(var.name) <= 26 && can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must be <= 26 chars and match [a-zA-Z0-9-] so \"${var.name}-tg\" stays within the 32-char target group limit."
  }
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target group are created"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB (at least two AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for an ALB."
  }
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener"
  type        = string
}

variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle timeout in seconds"
  type        = number
  default     = 60
}

variable "enable_http2" {
  description = "Enable HTTP/2 on the ALB"
  type        = bool
  default     = true
}

variable "http_port" {
  description = "HTTP listener port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS listener port"
  type        = number
  default     = 443
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Target type for the target group"
  type        = string
  default     = "instance"
}

variable "deregistration_delay" {
  description = "Deregistration delay in seconds"
  type        = number
  default     = 300
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port"
  type        = string
  default     = "traffic-port"
}

variable "health_check_matcher" {
  description = "Health check matcher"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Healthy threshold count"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count"
  type        = number
  default     = 3
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
