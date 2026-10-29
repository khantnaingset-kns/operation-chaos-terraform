data "terraform_remote_state" "network_stack" {
  backend = "s3"

  config = {
    bucket = "operation-chaos-tf-state-837411785224-ap-southeast-1-an"
    key    = "dev/stacks/network/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "storage_stack" {
  backend = "s3"

  config = {
    bucket = "operation-chaos-tf-state-837411785224-ap-southeast-1-an"
    key    = "dev/stacks/storage/terraform.tfstate"
    region = "ap-southeast-1"
  }
}