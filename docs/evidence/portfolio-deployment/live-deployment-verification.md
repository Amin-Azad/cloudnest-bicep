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

## Visual evidence

The successful live deployment was captured in Azure Portal and GitHub Actions before cleanup.

1. [GitHub Actions successful deployment](screenshots/01-github-success.png)
2. [Azure resource group inventory](screenshots/02-resource-group.png)
3. [Running B1 App Service and VNet integration](screenshots/03-app-service-running.png)
4. [Azure SQL Free database online](screenshots/04-sql-free-online.png)
5. [SQL public network access disabled](screenshots/05-sql-public-access-disabled.png)
6. [SQL private endpoint approved](screenshots/06-sql-private-endpoint-approved.png)
7. [Key Vault public network access disabled](screenshots/07-keyvault-public-access-disabled.png)
8. [Key Vault private endpoint approved](screenshots/08-keyvault-private-endpoint-approved.png)
9. [Storage security configuration](screenshots/09-storage-security-overview.png)
10. [Storage Blob and File private endpoints approved](screenshots/10-storage-private-endpoints-approved.png)
11. [VNet subnet segmentation](screenshots/11-vnet-subnet-segmentation.png)
12. [Web App system-assigned managed identity](screenshots/12-webapp-managed-identity.png)
13. [Managed identity RBAC assignments](screenshots/13-webapp-managed-identity-rbac.png)
14. [App Service diagnostic settings](screenshots/14-appservice-diagnostic-settings.png)
15. [HTTP 5xx alert rule](screenshots/15-http-5xx-alert-rule.png)
16. [Live App Service Plan metrics](screenshots/16-app-service-plan-live-metrics.png)
17. [High CPU alert rule](screenshots/17-high-cpu-alert-rule.png)
18. [Azure Policy compliance](screenshots/18-policy-compliance.png)
19. [Successful Azure deployment record](screenshots/19-azure-deployment-success.png)

## Controlled cleanup

After live verification and evidence capture, the portfolio workload was removed to stop ongoing cost.

Post-cleanup state:

- `rg-cloudnest-dev` recreated in North Europe
- Resource count: 0
- Bootstrap tags restored
- Portfolio policy assignments removed
- Deployment identity retained with:
  - Contributor at `rg-cloudnest-dev`
  - Resource Policy Contributor at `rg-cloudnest-dev`
  - Role Based Access Control Administrator at `rg-cloudnest-dev`
- Subscription-level Reader retained
- Key Vault remains only as an Azure soft-delete record with scheduled purge on 2026-11-19

The resource group and least-privilege deployment foundation were preserved so the environment can be redeployed later without keeping workload resources running.

20. [Post-cleanup empty resource group](screenshots/20-post-cleanup-empty-resource-group.png)
