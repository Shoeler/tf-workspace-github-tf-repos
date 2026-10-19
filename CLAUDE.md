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

Delegate to background subagents via the Agent tool for exploration, review, and multi-step or multi-file work. Keep small, obvious edits inline: a one-line change to `main.tf`, `variables.tf`, or `versions.tf` is cheaper to do directly than to brief an agent for.

Agent choice:

- Read-only exploration or locating code: `Explore` or `caveman:cavecrew-investigator`.
- Bounded edits to one or two `.tf` files that need `terraform fmt` and `validate` to confirm: `tf-module-fixer` or `caveman:cavecrew-builder`.
- Reviewing a diff or branch: `caveman:cavecrew-reviewer`.
- Larger or multi-step work: `general-purpose`.

Sharing context with agents:

- A fresh agent starts with no conversation memory. Front-load the prompt with the goal, exact files and line numbers, facts already established (for example, `customer_test` is intentionally commented out), constraints (no push, keep the `~> 1.0` pin), and the output shape wanted.
- For follow-up work on the same task, continue the existing agent with `SendMessage` instead of spawning a new one; it keeps its context and skips the cold start.
- Use `fork` only when the agent genuinely needs the conversation history. It copies the full context, so it is not cheaper than a fresh agent with a good brief.
- Agent reports are not shown to the user; relay what matters. Launch independent agents in parallel.
