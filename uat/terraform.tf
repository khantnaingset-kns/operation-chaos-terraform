terraform {
  required_version = "1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.58.0"
    }
  }

  backend "s3" {
    bucket       = "operation-chaos-tf-state-837411785224-ap-southeast-7-an"
    key          = "terraform.tfstate"
    region       = "ap-southeast-7"
    use_lockfile = true
  }
}
