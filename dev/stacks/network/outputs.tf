output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "isolated_subnet_ids" {
  description = "IDs of the isolated subnets"
  value       = module.vpc.isolated_subnet_ids
}

output "isolated_route_table_id" {
  description = "ID of the isolated route table"
  value       = module.vpc.isolated_route_table_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = module.alb.alb_security_group_id
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}

output "target_group_port" {
  description = "Port on which targets receive traffic"
  value       = module.alb.target_group_port
}
