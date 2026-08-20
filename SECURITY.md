# Security

CloudNest is a personal portfolio project and is not a production service.

## Current position

- GitHub pull-request validation has read-only repository permission and does not authenticate to Azure.
- External GitHub Actions are pinned to full commit SHAs.
- The application has a system-assigned Managed Identity in the Bicep design.
- Storage access is designed to use Managed Identity and RBAC.
- Application settings use a Key Vault reference for an application secret.
- Azure SQL still uses an administrator credential in this version. The rebuild will protect that credential with a secure workflow input and Key Vault reference.

The current infrastructure has not yet been revalidated end to end. Private SQL access, Key Vault RBAC, staging-slot permissions, App Service origin restrictions and direct-origin rejection remain rebuild work rather than completed security claims.

## Repository rules

Do not commit:

- passwords, tokens, connection strings or secret values
- subscription IDs, tenant IDs or object IDs
- personal email addresses
- generated private-endpoint NIC IDs or private IP addresses
- unsanitized Azure Portal screenshots
- active or obsolete generated service endpoints

Use `./scripts/check-repository-hygiene.sh` before committing. The same check runs in pull requests.

## Reporting

If you find a sensitive value in the repository, do not open a public issue containing it. Use GitHub's private vulnerability reporting feature when available.

Historical screenshots and output files were sanitized during the repository baseline cleanup. Future deployment evidence must be reviewed before it is committed.
