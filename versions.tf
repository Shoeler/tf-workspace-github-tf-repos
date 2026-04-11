terraform {
  cloud {
    organization = "<TFC_ORGANIZATION_PLACEHOLDER>"

    workspaces {
      name = "<TFC_WORKSPACE_NAME_PLACEHOLDER>"
    }
  }

  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57"
    }
  }
}

provider "github" {
  owner = var.github_org
}
