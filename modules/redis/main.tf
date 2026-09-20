resource "aws_security_group" "this" {
  name_prefix = "${var.name}-redis-"
  description = "Security group for ${var.name} Redis instance"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name}-redis-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id            = aws_security_group.this.id
  description                  = "Allow Redis from application instances"
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  referenced_security_group_id = var.client_security_group_id
}

data "aws_vpc_endpoint_service" "this" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_iam_role" "this" {
  name = "${var.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.name}-ec2-role" })
}

resource "aws_iam_role_policy" "this" {
  name = "${var.name}-s3-access"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListBucket"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
        Resource = var.s3_bucket_arn
      },
      {
        Sid      = "ReadWriteObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-ec2-profile"
  role = aws_iam_role.this.name

  tags = merge(var.tags, { Name = "${var.name}-ec2-profile" })
}

resource "aws_vpc_endpoint" "this" {
  vpc_id            = var.vpc_id
  service_name      = data.aws_vpc_endpoint_service.this.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowRedisRoleBucketActions"
        Effect    = "Allow"
        Action    = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
        Principal = { AWS = aws_iam_role.this.arn }
        Resource  = var.s3_bucket_arn
      },
      {
        Sid       = "AllowRedisRoleObjectActions"
        Effect    = "Allow"
        Action    = ["s3:GetObject", "s3:PutObject", "s3:AbortMultipartUpload", "s3:ListMultipartUploadParts"]
        Principal = { AWS = aws_iam_role.this.arn }
        Resource  = "${var.s3_bucket_arn}/*"
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.name}-s3-endpoint" })
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS to S3 through the gateway endpoint"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = aws_vpc_endpoint.this.prefix_list_id
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = false
  monitoring                  = var.enable_detailed_monitoring
  user_data                   = var.user_data
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.this.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "${var.name}-redis" })

  depends_on = [
    aws_vpc_security_group_egress_rule.this,
    aws_vpc_security_group_ingress_rule.this,
    aws_vpc_endpoint.this,
  ]
}
