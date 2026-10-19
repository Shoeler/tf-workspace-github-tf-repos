# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A root Terraform module, run in HCP Terraform, that provisions GitHub repositories and paired HCP Terraform workspaces. All real logic lives in the private registry module `app.terraform.io/schuyler-tfc/module-terraform-repo-workspace/github` (GitHub source: `Shoeler/tf-module-github-workspace-goldenpath`). This repo only declares module calls plus the variables and providers they need. There are no tests, no lint config, and no CI in this repo.

Each module call creates one GitHub repo named `<team>-<project>`, `main` and `dev` branches with branch protection, and two VCS-connected workspaces `<team>-<project>-main` and `<team>-<project>-dev`.

## Layout

- `main.tf`: one `module` block per repo/workspace pair. `platform_demo_app` is active. `customer_test` is commented out; it was disabled to destroy its resources for testing (commit `b2c1ad5`). Uncomment or add a block to provision.
- `variables.tf`: `github_org`, `tfe_organization`, `tfe_project_name`, and sensitive `oauth_token_id`. All are set as HCP Terraform workspace variables, not in tfvars.
- `versions.tf`: `cloud {}` backend block, provider version pins (`integrations/github ~> 6.0`, `hashicorp/tfe ~> 0.57`), and the `github` provider configured with `owner = var.github_org`. The `cloud` block still contains `<TFC_ORGANIZATION_PLACEHOLDER>` and `<TFC_WORKSPACE_NAME_PLACEHOLDER>`; fill these before running.

## Commands

```shell
terraform fmt -recursive
terraform init          # needs `terraform login` and the cloud block filled in
terraform validate
terraform plan
terraform apply
```

Running locally requires `GITHUB_TOKEN` exported in the shell (the `github` provider reads it from the environment; no token is set in the provider block) and `TF_VAR_oauth_token_id` plus the other `TF_VAR_*` values, or the matching workspace variables in HCP Terraform. `terraform destroy` of a repo needs a GitHub token with `delete_repo` (classic) or Administration read/write (fine-grained).

## Conventions

- Add a new repo by adding a `module` block in `main.tf` with `project`, `team`, `repo_visibility`, and the four pass-through variables, then add a row to the "Repos" table in `README.md`.
- Pin the module with `version = "~> 1.0"` style constraints; minor bumps are allowed on purpose (commit `d5d145f`).
- The README's "Usage" section still describes `<MODULE_SOURCE_PLACEHOLDER>` and `<MODULE_VERSION_PLACEHOLDER>` in `main.tf`; those were replaced with real values in `93013b5`, so the README is slightly stale on that point.
- The README is the authoritative setup guide for the GitHub token and VCS OAuth token ID (`ot-...`); update it when provider or variable requirements change.

## Working style

Always delegate work to background subagents via the Agent tool rather than doing it inline in the main thread. Choose the agent type that fits the task:

- Read-only exploration or locating code: `Explore` or `caveman:cavecrew-investigator`.
- Small bounded edits to one or two `.tf` files (`main.tf`, `variables.tf`, `versions.tf`): `tf-module-fixer` or `caveman:cavecrew-builder`.
- Reviewing a diff or branch: `caveman:cavecrew-reviewer`.
- Anything larger or multi-step: `general-purpose`, or `fork` when the agent needs the current conversation context.

Run agents in the background, launch independent agents in parallel, and relay their results to the user, since the agent's final report is not shown directly. Trivial one-line answers that need no tool calls may be answered directly.
