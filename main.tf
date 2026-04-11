module "customer_test" {
  source  = "<MODULE_SOURCE_PLACEHOLDER>"
  version = "<MODULE_VERSION_PLACEHOLDER>"

  project          = "customer-test"
  team             = "hashi-se"
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
}
