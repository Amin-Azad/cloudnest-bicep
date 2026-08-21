# CloudNest Portfolio Deployment Verification

## Successful deployment

GitHub Actions run:

- Run ID: 32493574301
- Workflow: Dev Deployment
- Event: workflow_dispatch
- Branch: feat/free-tier-portfolio-profile
- Commit: 38baae78f9e61a99d9793413c0c1cc6e361b7e71
- Result: success

Azure deployment:

- Deployment: cloudnest-portfolio-32493574301
- Provisioning state: Succeeded
- Region: Sweden Central
- Correlation ID: f5497ff4-3ac8-4b2e-a294-847501889abe

## Compute and application hosting

App Service:

- Plan: asp-cloudnest-portfolio
- SKU: B1
- Tier: Basic
- Capacity: 1
- Web App: webapp-cloudnest-portfolio-v3vrhghhmkzdo
- State: Running
- HTTPS only: enabled
- Managed identity: SystemAssigned
- VNet integration: snet-app

## Database

Azure SQL:

- Server: sql-cloudnest-portfolio-jilitma5v2l3q
- Database: sqldb-cloudnest-portfolio
- SKU: Free
- Status: Online
- Maximum size: 33554432 bytes
- Public network access: Disabled
- Minimum TLS: 1.2

The 32 MiB database size reflects the Free SQL capability exposed by this subscription in Sweden Central.

## Network

VNet:

- vnet-cloudnest-portfolio

Subnets:

- snet-app — 10.30.1.0/24 — Succeeded
- snet-data — 10.30.2.0/24 — Succeeded
- snet-private — 10.30.3.0/24 — Succeeded

Private endpoints:

- pep-cloudnest-blob-portfolio — Succeeded / Approved
- pep-cloudnest-file-portfolio — Succeeded / Approved
- pep-cloudnest-kv-portfolio — Succeeded / Approved
- pep-cloudnest-sql-portfolio — Succeeded / Approved

Private DNS zones and VNet links were created for:

- Azure SQL
- Blob Storage
- File Storage
- Key Vault

## Storage security

Storage account:

- stportfoliojilitma5v2l3q
- Public network access: Disabled
- Anonymous blob access: Disabled
- HTTPS only: enabled
- Minimum TLS: 1.2

## Key Vault security

Key Vault:

- kvportfoliojilitma5v2l3q
- Public network access: Disabled
- RBAC authorization: enabled
- Soft delete: enabled

## Managed identity access

The Web App system-assigned managed identity received:

- Key Vault Secrets User on the portfolio Key Vault
- Storage Blob Data Reader on the portfolio Storage Account

## Azure Policy

Active portfolio policies:

- CloudNest - Allowed locations
- CloudNest - Deny public blob access
- CloudNest - Inherit project tag from resource group
- CloudNest - Inherit environment tag from resource group
- CloudNest - Inherit owner tag from resource group

The original hard require-tag policies were removed from the portfolio profile after live deployment showed that they blocked Azure Private DNS virtual network link resources.

## Monitoring and diagnostics

Diagnostic settings confirmed:

- diag-appservice-primary
- diag-sql-database
- diag-keyvault
- diag-storage-blob
- diag-storage-file

All are connected to:

- law-cloudnest-portfolio

Monitoring resources also include:

- Application Insights
- action group
- high CPU alert
- HTTP 5xx alert

## Deployment findings

The real deployment exposed several issues that static validation alone did not reveal:

1. GitHub OIDC federation initially used a subject that did not match the token emitted by the repository environment.
2. The least-privilege deployment identity required narrowly scoped policy-assignment and RBAC-assignment permissions.
3. Azure SQL Free on this subscription exposed a 32 MiB maximum database size.
4. Hard require-tag policies blocked Private DNS VNet link resources.
5. Parallel subnet writes caused Microsoft.Network AnotherOperationInProgress failures.
6. Subnet provisioning was serialized in Bicep to remove the race condition.

Each finding was corrected without broadening deployment scope to subscription Owner.

## Result

The constrained CloudNest portfolio environment was successfully deployed from Bicep through a guarded GitHub Actions workflow, then validated against the live Azure control plane.

The full production-style architecture remains in the repository. The portfolio profile demonstrates a smaller deployment adapted to actual subscription, quota and cost constraints.
