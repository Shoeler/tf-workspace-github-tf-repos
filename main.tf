# module "customer_test" {
#   source  = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
#   version = "~> 1.0"

#   project          = "customer-test"
#   team             = "hashi-se"
#   github_org       = var.github_org
#   tfe_organization = var.tfe_organization
#   oauth_token_id   = var.oauth_token_id
#   repo_visibility  = "public"
#   tfe_project_name = var.tfe_project_name
# }

module "platform_demo_app" {
  source  = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
  version = "~> 1.0"

  project          = "demo-app"
  team             = "platform"
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
  repo_visibility  = "public"
  tfe_project_name = var.tfe_project_name
}

module "migration_test_a" {
  source  = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
  version = "~> 1.0"

  project          = "migration-test-a"
  team             = "platform"
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
  repo_visibility  = "public"
  tfe_project_name = var.tfe_project_name
}

module "migration_test_b" {
  source  = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
  version = "~> 1.0"

  project          = "migration-test-b"
  team             = "platform"
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
  repo_visibility  = "public"
  tfe_project_name = var.tfe_project_name
}
