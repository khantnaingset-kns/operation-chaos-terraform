output "instance_id" {
  description = "ID of the Redis EC2 instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the Redis instance"
  value       = aws_instance.this.private_ip
}

output "private_dns" {
  description = "Private DNS name of the Redis instance"
  value       = aws_instance.this.private_dns
}

output "security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.this.id
}

output "port" {
  description = "Port Redis listens on"
  value       = var.port
}

output "endpoint" {
  description = "Redis endpoint as <private-dns>:<port>"
  value       = "${aws_instance.this.private_dns}:${var.port}"
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint"
  value       = aws_vpc_endpoint.this.id
}

output "iam_role_arn" {
  description = "ARN of the Redis EC2 IAM role"
  value       = aws_iam_role.this.arn
}

output "instance_profile_arn" {
  description = "ARN of the Redis EC2 instance profile"
  value       = aws_iam_instance_profile.this.arn
}
