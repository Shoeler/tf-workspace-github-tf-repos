variable "github_org" {
  description = "GitHub organization under which repositories will be created. Sourced from HCP Terraform workspace variable."
  type        = string
}

variable "tfe_organization" {
  description = "HCP Terraform organization under which workspaces will be created. Sourced from HCP Terraform workspace variable."
  type        = string
}

variable "oauth_token_id" {
  description = "HCP Terraform VCS OAuth token ID used to connect workspaces to GitHub. Sourced from HCP Terraform workspace sensitive variable."
  type        = string
  sensitive   = true
}

variable "tfe_project_name" {
  description = "HCP Terraform project name under which workspaces will be created. Sourced from HCP Terraform workspace variable."
  type        = string
}
