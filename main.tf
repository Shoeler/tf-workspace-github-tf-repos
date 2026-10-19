# One entry per repo/workspace pair. The key is the module instance name and
# the GitHub repo is named "<team>-<project>". Add a new entry here and the
# outputs in outputs.tf pick it up automatically.
locals {
  repos = {
    # customer_test = {
    #   project         = "customer-test"
    #   team            = "hashi-se"
    #   repo_visibility = "public"
    # }

    platform_demo_app = {
      project         = "demo-app"
      team            = "platform"
      repo_visibility = "public"
    }

    migration_test_a = {
      project         = "migration-test-a"
      team            = "platform"
      repo_visibility = "public"
    }

    migration_test_b = {
      project         = "migration-test-b"
      team            = "platform"
      repo_visibility = "public"
    }
  }
}

module "repo" {
  source   = "app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github"
  version  = "~> 1.0"
  for_each = local.repos

  project          = each.value.project
  team             = each.value.team
  github_org       = var.github_org
  tfe_organization = var.tfe_organization
  oauth_token_id   = var.oauth_token_id
  repo_visibility  = try(each.value.repo_visibility, "public")
  tfe_project_name = var.tfe_project_name
}

# Existing instances were created as standalone module blocks before the
# for_each refactor. These keep their state in place instead of recreating.
moved {
  from = module.platform_demo_app
  to   = module.repo["platform_demo_app"]
}

moved {
  from = module.migration_test_a
  to   = module.repo["migration_test_a"]
}

moved {
  from = module.migration_test_b
  to   = module.repo["migration_test_b"]
}
