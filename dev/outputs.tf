output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "target_group_port" {
  description = "Port on which targets receive traffic"
  value       = module.alb.target_group_port
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = module.autoscaling.autoscaling_group_name
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.autoscaling.ec2_security_group_id
}

output "redis_instance_id" {
  description = "ID of the Redis EC2 instance"
  value       = module.redis.instance_id
}

output "redis_private_ip" {
  description = "Private IP address of the Redis instance"
  value       = module.redis.private_ip
}

output "redis_private_dns" {
  description = "Private DNS name of the Redis instance"
  value       = module.redis.private_dns
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = module.redis.security_group_id
}

output "redis_port" {
  description = "Port Redis listens on"
  value       = module.redis.port
}

output "redis_endpoint" {
  description = "Redis endpoint as <private-dns>:<port>"
  value       = module.redis.endpoint
}

output "s3_bucket_id" {
  description = "ID (name) of the S3 bucket"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "redis_s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint used by Redis"
  value       = module.redis.s3_gateway_endpoint_id
}

output "redis_iam_role_arn" {
  description = "ARN of the Redis EC2 IAM role"
  value       = module.redis.iam_role_arn
}
