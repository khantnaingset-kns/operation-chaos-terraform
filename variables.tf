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