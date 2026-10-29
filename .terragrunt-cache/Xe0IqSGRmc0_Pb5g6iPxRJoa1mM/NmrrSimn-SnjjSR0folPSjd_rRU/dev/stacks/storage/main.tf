module "s3" {
  source = "../../../modules/s3"

  name = var.s3_name
  tags = var.s3_tags
}


