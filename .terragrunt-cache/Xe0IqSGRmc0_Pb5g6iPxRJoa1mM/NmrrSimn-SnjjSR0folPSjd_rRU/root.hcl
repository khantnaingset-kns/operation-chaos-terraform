remote_state {
    backend = "s3"

    generate {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
    
    config = {
        bucket         = "operation-chaos-tf-state-837411785224-ap-southeast-1-an"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "us-west-2"
        encrypt        = true
        use_lockfile = true
    }
}