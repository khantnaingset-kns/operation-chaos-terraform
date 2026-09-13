# AGENTS.md

## Repository Structure

This repository contains a single deployable Terraform stack at the repository root.

```text
.
├── main.tf
├── variables.tf
├── providers.tf
├── terraform.tf
├── data.tf
└── modules/
    ├── *
```

* Root configuration composes the infrastructure.
* Modules folder under the `./modules` are reusable child modules.
* `CLAUDE.md` is a symlink to this file. Do not maintain it separately.

## Toolchain

* Terraform: `1.15.8`
* AWS provider: `6.58.0`
* `.terraform.lock.hcl` is committed.

Preserve exact version pins unless explicitly asked to upgrade.

Initialize clean checkouts with:

```bash
terraform init
```

Do not routinely use:

```bash
terraform init -upgrade
```

## Validation

For Terraform source changes, run from the repository root:

```bash
terraform fmt -check -recursive
terraform validate
```

Do not use `terraform plan` for routine source validation because it may depend on local inputs, state, credentials, and AWS access.

Never run:

```bash
terraform apply
terraform destroy
```

without explicit user approval.

For documentation-only changes:

```bash
git diff --check
```

Terraform validation is unnecessary unless Terraform source changed.

## Code Structure

* Use snake case for name label.
* If there is not duplicate resources use variable name as `this`.
* Do not use overly complicated locals computed blocks.

## File Structure
* Keep file structure as below
    * `main.tf` for terraform resources
    * `outputs.tf` for module outputs.
    * `variables.tf` for terraform variables
    * `provider.tf` for provider configs
    * `terraform.tf` for terraform main configs and backend config
* Do not create another `*.tf` file that is deviate from above flow.

## Editing Guidelines

* Keep changes scoped to the requested task.
* Read the root configuration before modifying child modules.
* Check module inputs and outputs before changing module interfaces.
* Avoid unnecessary resource renames or address changes.
* Be careful when changing ordered lists used with `count`; reordering may change resource identity.
* Do not assume network connectivity solely from the presence of routes or route tables.
* Do not modify generated Terraform files.

## State and Secrets

Do not inspect, expose, modify, or commit:

* `.terraform/`
* Terraform state files
* `*.tfvars`
* Terraform CLI configuration
* crash logs
* override files
* credentials, keys, or certificates

Saved Terraform plan files may contain sensitive information. Do not create or commit them unless explicitly requested.

## Before Finishing

* Review the diff for unrelated changes.
* Run the applicable validation commands.
* Run `git diff --check`.
* Confirm no state, secrets, plans, or generated Terraform files were added.
* If this file changed, confirm `CLAUDE.md` still resolves to `AGENTS.md`.
* Do not run terraform plan, apply or destroy.
* Do not commit or open PR.
