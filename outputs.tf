output "repo_urls" {
  description = "GitHub repository URLs (web, SSH clone, HTTPS clone) keyed by entry in local.repos."
  value       = { for k, m in module.repo : k => m.repo_urls }
}

output "workspace_urls" {
  description = "HCP Terraform workspace UI URLs (main, then dev) keyed by entry in local.repos."
  value       = { for k, m in module.repo : k => m.workspace_urls }
}
