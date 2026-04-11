module "customer_test" {
  source  = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
  version = "1.0.1"

  project          = "customer-test"
  team             = "hashi-se"
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
}