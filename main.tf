module "vpc" {
  source = "./modules/vpc"

  vpc_name              = var.vpc_name
  cidr_block            = var.cidr_block
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  isolated_subnet_cidrs = var.isolated_subnet_cidrs
  azs                   = var.azs

}

module "alb" {
  source = "./modules/alb"

  name              = var.alb_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  idle_timeout      = var.alb_idle_timeout
  target_group_port = var.application_port
  target_type       = "instance"

  depends_on = [module.vpc]
}

module "autoscaling" {
  source = "./modules/autoscaling"

  name                  = var.autoscaling_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  target_group_port     = module.alb.target_group_port

  ami_id                    = var.autoscaling_ami_id
  instance_type             = var.autoscaling_instance_type
  user_data                 = var.autoscaling_user_data
  min_size                  = var.autoscaling_min_size
  max_size                  = var.autoscaling_max_size
  desired_capacity          = var.autoscaling_desired_capacity
  health_check_grace_period = var.autoscaling_health_check_grace_period
  instance_warmup           = var.autoscaling_instance_warmup
  cpu_target_value          = var.autoscaling_cpu_target_value

  depends_on = [module.vpc]
}

module "s3" {
  source = "./modules/s3"

  name = var.s3_name
  tags = var.s3_tags
}

module "redis" {
  source = "./modules/redis"

  name                     = var.redis_name
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.isolated_subnet_ids[0]
  route_table_id           = module.vpc.isolated_route_table_id
  client_security_group_id = module.autoscaling.ec2_security_group_id
  s3_bucket_arn            = module.s3.bucket_arn

  ami_id                     = var.redis_ami_id
  instance_type              = var.redis_instance_type
  port                       = var.redis_port
  user_data                  = var.redis_user_data
  enable_detailed_monitoring = var.redis_enable_detailed_monitoring
  tags                       = var.redis_tags
}

resource "aws_s3_bucket_policy" "this" {
  bucket = module.s3.bucket_id

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
        Resource = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
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
        Resource  = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
