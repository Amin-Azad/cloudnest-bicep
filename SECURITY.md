# Security

CloudNest is a personal portfolio project, not a production service. I still tried to keep the deployed profile as close as possible to the security model in the Bicep design.

## What was verified

The portfolio deployment used private endpoints for Azure SQL, Storage Blob, Storage File and Key Vault. Public network access was disabled for SQL, Storage and Key Vault.

The Web App used a system-assigned Managed Identity. It received Key Vault Secrets User on the Key Vault and Storage Blob Data Reader on the Storage Account.

Azure SQL had minimum TLS 1.2 and public network access disabled. Storage also used HTTPS only, minimum TLS 1.2 and anonymous blob access disabled. Key Vault used RBAC authorization and soft delete.

These were checked from the live Azure environment before cleanup. The screenshots and details are in [portfolio deployment verification](docs/evidence/portfolio-deployment/live-deployment-verification.md).

## GitHub and Azure access

GitHub Actions uses OIDC to sign in to Azure. I did not store an Azure client secret in GitHub.

The deployment workflow only has `contents: read` and `id-token: write` permissions from GitHub.

The deployment identity was kept away from subscription Owner. After cleanup it retained Contributor, Resource Policy Contributor and Role Based Access Control Administrator on `rg-cloudnest-dev`, with Reader at subscription scope.

This was enough for the deployment work without giving wider access than I needed.

## SQL credential

Azure SQL still uses an administrator login and password in this version. The password is passed from a GitHub secret into the deployment and is not committed to the repository.

This is one area I would improve later with passwordless SQL authentication, but I did not want to claim it before implementing and testing it.

## Repository rules

I do not commit passwords, tokens, connection strings, subscription IDs, tenant IDs, object IDs, personal email addresses, private endpoint IPs or unsanitized Azure screenshots.

`./scripts/check-repository-hygiene.sh` is used to check the repository before commits and the same check also runs in pull request validation.

## Deployment findings

The real deployment also helped me find security and permission issues which I could not see only from local validation.

The GitHub OIDC subject had to match the token created for the repository environment. The deployment identity also needed a few specific RBAC and policy permissions. I added only the permissions needed for that scope instead of using subscription Owner.

Azure Policy also needed adjustment because hard require-tag policies blocked Private DNS virtual network link resources. I kept the useful policy controls but changed the portfolio profile so the deployment could work correctly.

## Reporting

If a sensitive value is found in this repository, it should not be posted in a public issue. GitHub private vulnerability reporting should be used when available.
