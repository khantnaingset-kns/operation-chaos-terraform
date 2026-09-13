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

module "redis" {
  source = "./modules/redis"

  name                     = var.redis_name
  vpc_id                   = module.vpc.vpc_id
  subnet_id                = module.vpc.isolated_subnet_ids[0]
  client_security_group_id = module.autoscaling.ec2_security_group_id

  ami_id                     = var.redis_ami_id
  instance_type              = var.redis_instance_type
  port                       = var.redis_port
  user_data                  = var.redis_user_data
  enable_detailed_monitoring = var.redis_enable_detailed_monitoring
  tags                       = var.redis_tags
}
