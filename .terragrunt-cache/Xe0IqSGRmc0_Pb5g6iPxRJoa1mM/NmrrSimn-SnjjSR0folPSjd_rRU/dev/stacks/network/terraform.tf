terraform {
  required_version = "1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.58.0"
    }
  }

  backend "s3" {
    bucket       = "operation-chaos-tf-state-837411785224-ap-southeast-1-an"
    key          = "dev/stacks/network/terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
  }
}
