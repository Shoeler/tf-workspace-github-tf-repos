# tf-workspace-github-tf-repos

Root Terraform module that provisions GitHub repositories and paired HCP Terraform workspaces using the [`tf-module-github-workspace-goldenpath`](https://github.com/Shoeler/tf-module-github-workspace-goldenpath) module.

Each module call creates:
- A GitHub repository (`<team>-<project>`)
- Two long-lived branches: `main` and `dev`
- Branch protection on both branches (PR required, stale review dismissal)
- Two HCP Terraform workspaces (`<team>-<project>-main`, `<team>-<project>-dev`) connected via VCS

## Prerequisites

- HCP Terraform workspace with the variables below configured
- A VCS OAuth connection between HCP Terraform and GitHub (see [Creating the OAuth Token ID](#creating-the-oauth-token-id))
- A GitHub token the GitHub provider can use to create repositories (see [Creating a GitHub Token](#creating-a-github-token))

## HCP Terraform Variables

Set the following as workspace variables in HCP Terraform before running. Mark `oauth_token_id` and `GITHUB_TOKEN` as **sensitive**.

| Variable | Type | Sensitive | Description |
|---|---|---|---|
| `github_org` | Terraform | No | GitHub organization where repositories are created |
| `tfe_organization` | Terraform | No | HCP Terraform organization where workspaces are created |
| `oauth_token_id` | Terraform | **Yes** | VCS OAuth token ID linking HCP Terraform to GitHub |
| `GITHUB_TOKEN` | Environment | **Yes** | GitHub token the GitHub provider uses to create and manage repositories |

## Creating a GitHub Token

The `github` provider block in [`versions.tf`](versions.tf) does not set a token, so the provider reads it from the `GITHUB_TOKEN` environment variable. The token must be able to create repositories, push branches, and manage branch protection in the organization set in `github_org`.

### Fine-grained personal access token (recommended)

1. In GitHub, go to **Settings → Developer settings → Personal access tokens → Fine-grained tokens** and click **Generate new token**.
2. Give the token a name and an expiration.
3. Under **Resource owner**, select the organization that matches `github_org`. If the organization is not listed, an organization owner needs to allow fine-grained tokens under the organization's **Settings → Personal access tokens**.
4. Under **Repository access**, select **All repositories**. The token has to cover repositories that do not exist yet, so selecting individual repositories will not work.
5. Under **Repository permissions**, set:

   | Permission | Access | Used for |
   |---|---|---|
   | Administration | Read and write | Creating and deleting repositories, branch protection |
   | Contents | Read and write | Creating the `main` and `dev` branches |
   | Metadata | Read-only | Selected automatically |

6. Click **Generate token** and copy the value. GitHub only shows it once.
7. If the organization requires approval for fine-grained tokens, an organization owner must approve the request before the token works.

### Classic personal access token

If fine-grained tokens are not enabled for the organization, create a classic token instead:

1. Go to **Settings → Developer settings → Personal access tokens → Tokens (classic)** and click **Generate new token (classic)**.
2. Select the `repo` scope. Add `delete_repo` if you want `terraform destroy` to be able to remove repositories.
3. Click **Generate token** and copy the value.
4. If the organization enforces SAML single sign-on, click **Configure SSO** next to the token and authorize it for the organization.

### Adding the token to HCP Terraform

1. Open the workspace for this root module in HCP Terraform and go to **Variables**.
2. Under **Workspace variables**, click **Add variable**.
3. Select **Environment variable**, set the key to `GITHUB_TOKEN`, and paste the token as the value.
4. Check **Sensitive** and save.

For a local run, export the token in your shell instead:

```shell
export GITHUB_TOKEN=<your token>
```

## Creating the OAuth Token ID

The module connects each workspace it creates to its GitHub repository through an HCP Terraform VCS provider. `oauth_token_id` is the ID of the OAuth token that HCP Terraform stores for that provider. It starts with `ot-`, and it is created when you add GitHub as an OAuth-based VCS provider in the organization set in `tfe_organization`.

The VCS provider must be the OAuth type, **GitHub.com (Custom)**. The preconfigured **GitHub App** option does not produce an OAuth token ID.

### Adding the VCS provider

You need permission to manage VCS settings for the HCP Terraform organization. Keep HCP Terraform and GitHub open in separate tabs, because the steps move between them. These steps follow HashiCorp's [GitHub.com (OAuth) guide](https://developer.hashicorp.com/terraform/cloud-docs/vcs/github).

1. In HCP Terraform, choose **Settings** from the organization sidebar, then click **Providers**. Click **Add a VCS provider**.
2. Select **GitHub**, then **GitHub.com (Custom)**. Leave this page open.
3. Click the link on that page to register a new OAuth application, or open `https://github.com/settings/applications/new` in GitHub.
4. Fill in the GitHub form and click **Register application**:

   | Field | Value |
   |---|---|
   | Application name | `HCP Terraform (<your organization name>)` |
   | Homepage URL | `https://app.terraform.io` |
   | Application description | Anything you like |
   | Authorization callback URL | The callback URL shown in HCP Terraform |

5. On the application page in GitHub, copy the **Client ID**, then click **Generate a new client secret** and copy the secret. GitHub only shows it once.
6. Back in HCP Terraform, optionally give the provider a **Name**, paste the **Client ID** and **Client Secret**, and click **Connect and continue**.
7. GitHub asks you to authorize the application. Click **Request** or **Grant** next to the organization set in `github_org`, then click **Authorize**.
8. On the **Advanced settings** step, leave the scope at **All Projects** unless you want to limit the provider to selected projects. Make sure the project in `tfe_project_name` is covered. Click **Skip and finish** unless you need an SSH keypair for SSH-based Git submodules.
9. If the GitHub organization uses OAuth app access restrictions, an organization owner has to approve the request before HCP Terraform can reach the organization's repositories.

The GitHub account that authorizes the application in step 7 must have admin access to the repositories this module creates, because creating webhooks requires admin permissions.

### Finding the token ID

After the provider is added, go back to **Settings → Providers**. The **OAuth Token ID** column shows a value such as `ot-hmAyP66qk2AMVdbJ`. That value is `oauth_token_id`.

You can also read it from the API, using an HCP Terraform API token. First list the organization's OAuth clients to get the client ID, which starts with `oc-`:

```shell
curl -s \
  --header "Authorization: Bearer $TFE_TOKEN" \
  https://app.terraform.io/api/v2/organizations/<your organization>/oauth-clients
```

Then list the tokens for that client. The `id` in the response is `oauth_token_id`:

```shell
curl -s \
  --header "Authorization: Bearer $TFE_TOKEN" \
  https://app.terraform.io/api/v2/oauth-clients/<oauth client ID>/oauth-tokens
```

### Adding the token ID to HCP Terraform

1. Open the workspace for this root module in HCP Terraform and go to **Variables**.
2. Under **Workspace variables**, click **Add variable**.
3. Select **Terraform variable**, set the key to `oauth_token_id`, and paste the token ID as the value.
4. Check **Sensitive** and save.

For a local run, export the value in your shell instead:

```shell
export TF_VAR_oauth_token_id=<your token ID>
```

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
