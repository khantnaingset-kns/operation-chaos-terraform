module "autoscaling" {
  source = "../../../modules/autoscaling"

  name                  = var.autoscaling_name
  vpc_id                = data.terraform_remote_state.network_stack.outputs.vpc_id
  private_subnet_ids    = data.terraform_remote_state.network_stack.outputs.private_subnet_ids
  alb_security_group_id = data.terraform_remote_state.network_stack.outputs.alb_security_group_id
  target_group_arn      = data.terraform_remote_state.network_stack.outputs.target_group_arn
  target_group_port     = data.terraform_remote_state.network_stack.outputs.target_group_port

  ami_id                    = var.autoscaling_ami_id
  instance_type             = var.autoscaling_instance_type
  user_data                 = var.autoscaling_user_data
  min_size                  = var.autoscaling_min_size
  max_size                  = var.autoscaling_max_size
  desired_capacity          = var.autoscaling_desired_capacity
  health_check_grace_period = var.autoscaling_health_check_grace_period
  instance_warmup           = var.autoscaling_instance_warmup
  cpu_target_value          = var.autoscaling_cpu_target_value

}


module "redis" {
  source = "../../../modules/redis"

  name                     = var.redis_name
  vpc_id                   = data.terraform_remote_state.network_stack.outputs.vpc_id
  subnet_id                = data.terraform_remote_state.network_stack.outputs.isolated_subnet_ids[0]
  route_table_id           = data.terraform_remote_state.network_stack.outputs.isolated_route_table_id
  client_security_group_id = data.terraform_remote_state.network_stack.outputs.alb_security_group_id
  s3_bucket_arn            = data.terraform_remote_state.storage_stack.outputs.s3_bucket_arn

  ami_id                     = var.redis_ami_id
  instance_type              = var.redis_instance_type
  port                       = var.redis_port
  user_data                  = var.redis_user_data
  enable_detailed_monitoring = var.redis_enable_detailed_monitoring
  tags                       = var.redis_tags
}

resource "aws_s3_bucket_policy" "this" {
  bucket = data.terraform_remote_state.storage_stack.outputs.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyDataAccessOutsideVpcEndpoint"
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
        ]
        Resource = [data.terraform_remote_state.storage_stack.outputs.s3_bucket_arn, "${data.terraform_remote_state.storage_stack.outputs.s3_bucket_arn}/*"]
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = module.redis.s3_gateway_endpoint_id
          }
        }
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = { AWS = "*" }
        Action    = "s3:*"
        Resource  = [data.terraform_remote_state.storage_stack.outputs.s3_bucket_arn, "${data.terraform_remote_state.storage_stack.outputs.s3_bucket_arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
