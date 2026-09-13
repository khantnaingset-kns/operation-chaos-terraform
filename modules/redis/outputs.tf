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
