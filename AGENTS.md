# Terraform Workflow

- Use Terraform `1.15.8` exactly and AWS provider `6.58.0`; both are exact-pinned in `terraform.tf`, and `.terraform.lock.hcl` is committed.
- On a clean checkout, run `terraform init`. Do not use `terraform init -upgrade` unless intentionally changing the pinned dependency, and commit any intentional lockfile update.
- Routine verification is `terraform fmt -check -recursive` followed by `terraform validate`. There is no test suite or CI configuration.
- For a module-only formatting check, use `terraform fmt -check modules/<module>`; still run `terraform validate` at the root because that is where local modules are composed.

# Stack Boundaries

- The repository root is the deployable stack. `main.tf` wires `modules/vpc` public subnet outputs into `modules/alb`; the modules are not separate environments.
- The VPC module creates three subnet classes, an internet gateway, and one NAT gateway in the first public subnet, but no route tables or routes. Do not assume any subnet currently has routed internet access.
- The ALB module creates HTTP-to-HTTPS listeners, a target group, and an internet-open listener security group, but no target attachments. Its inputs require at least two public subnet IDs, an ACM certificate ARN, and an ALB name no longer than 26 characters.

# State And Cloud Safety

- No backend is configured, so Terraform uses ignored local state. `terraform.tfstate`, backups, `.terraform/`, and `terraform.tfvars` may exist locally but are not shared repository state.
- Treat ignored `*.tfvars` and state files as sensitive; never commit them or expose their contents in output.
- Do not use `terraform plan` as routine validation: it auto-loads the local `terraform.tfvars`, reads local state, and contacts AWS. Run `plan` only when cloud evaluation is intended, and run `apply` or `destroy` only with explicit user approval.
