# tf-workspace-github-tf-repos

Root Terraform module that provisions GitHub repositories and paired HCP Terraform workspaces using the [`tf-module-github-workspace-goldenpath`](https://github.com/Shoeler/tf-module-github-workspace-goldenpath) module.

Each module call creates:
- A GitHub repository (`<team>-<project>`)
- Two long-lived branches: `main` and `dev`
- Branch protection on both branches (PR required, stale review dismissal)
- Two HCP Terraform workspaces (`<team>-<project>-main`, `<team>-<project>-dev`) connected via VCS

## Prerequisites

- HCP Terraform workspace with the variables below configured
- A VCS OAuth connection between HCP Terraform and GitHub

## HCP Terraform Variables

Set the following as workspace variables in HCP Terraform before running. Mark `oauth_token_id` as **sensitive**.

| Variable | Type | Sensitive | Description |
|---|---|---|---|
| `github_org` | Terraform | No | GitHub organization where repositories are created |
| `tfe_organization` | Terraform | No | HCP Terraform organization where workspaces are created |
| `oauth_token_id` | Terraform | **Yes** | VCS OAuth token ID linking HCP Terraform to GitHub |

## Usage

1. Fill in the placeholders in [`versions.tf`](versions.tf):
   - `<TFC_ORGANIZATION_PLACEHOLDER>` — your HCP Terraform organization name
   - `<TFC_WORKSPACE_NAME_PLACEHOLDER>` — the workspace name for this root module

2. Fill in the placeholders in [`main.tf`](main.tf):
   - `<MODULE_SOURCE_PLACEHOLDER>` — registry path or local path to the module
   - `<MODULE_VERSION_PLACEHOLDER>` — module version to pin

3. Authenticate to HCP Terraform and run:

```shell
terraform init
terraform plan
terraform apply
```

## Repos

| Module call | Project | Team | Repo name |
|---|---|---|---|
| `customer_test` | `customer-test` | `hashi-se` | `hashi-se-customer-test` |
