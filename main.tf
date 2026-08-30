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

  name            = var.alb_name
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  certificate_arn = var.certificate_arn
}
