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
