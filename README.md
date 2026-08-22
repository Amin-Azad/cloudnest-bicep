# CloudNest

CloudNest is a personal Azure project I built to practice infrastructure as code, secure networking and deployment automation.

The repository contains a larger production-style Bicep design and a smaller portfolio profile that I deployed successfully in Azure. I kept the two separate because my subscription had quota and cost limits.

## What I deployed

The portfolio profile ran in Sweden Central and was deployed through a guarded GitHub Actions workflow using OpenID Connect (OIDC).

The deployed environment included:

- one B1 Linux App Service with VNet integration;
- Azure SQL Free with public network access disabled;
- a Storage account and Key Vault with public network access disabled;
- four approved private endpoints for SQL, Blob Storage, File Storage and Key Vault;
- private DNS zones and virtual network links;
- a system-assigned Managed Identity with scoped Key Vault and Storage RBAC;
- Log Analytics, Application Insights, diagnostic settings and alerts;
- Azure Policy assignments and tagging controls.

I verified 32 live resources before cleanup. Azure Policy reported 31 compliant resources out of 31 evaluated, with no non-compliant policies.

The deployment record and supporting screenshots are here:

- [Live deployment verification](docs/evidence/portfolio-deployment/live-deployment-verification.md)
- [Deployment qualification](docs/evidence/portfolio-deployment/qualification-summary.md)
- [Successful GitHub Actions deployment](docs/evidence/portfolio-deployment/screenshots/01-github-success.png)
- [Running App Service](docs/evidence/portfolio-deployment/screenshots/03-app-service-running.png)
- [Azure SQL Free online](docs/evidence/portfolio-deployment/screenshots/04-sql-free-online.png)
- [Approved SQL private endpoint](docs/evidence/portfolio-deployment/screenshots/06-sql-private-endpoint-approved.png)
- [Approved Key Vault private endpoint](docs/evidence/portfolio-deployment/screenshots/08-keyvault-private-endpoint-approved.png)
- [Approved Storage private endpoints](docs/evidence/portfolio-deployment/screenshots/10-storage-private-endpoints-approved.png)
- [Managed Identity RBAC assignments](docs/evidence/portfolio-deployment/screenshots/13-webapp-managed-identity-rbac.png)
- [Azure Policy compliance](docs/evidence/portfolio-deployment/screenshots/18-policy-compliance.png)
- [Successful Azure deployment](docs/evidence/portfolio-deployment/screenshots/19-azure-deployment-success.png)

## What the full design includes

The larger Bicep design also includes a disaster-recovery region, Azure Front Door with WAF, an App Service deployment slot and autoscaling.

Those features are implemented in the repository, but they were disabled in the portfolio deployment. I do not present them as live-tested resources.

The deployed profile used:

```text
enableDr             = false
enableFrontDoor      = false
enableDeploymentSlot = false
enableAutoscale      = false
```

This kept the real deployment within the available subscription, quota and cost limits.

## Security

SQL, Storage and Key Vault were deployed with public network access disabled. Access to those services used approved private endpoints and private DNS.

The Web App used a system-assigned Managed Identity with:

- Key Vault Secrets User on the Key Vault;
- Storage Blob Data Reader on the Storage account.

GitHub Actions authenticated to Azure through OIDC. No Azure client secret was stored in GitHub, and the deployment identity did not have subscription Owner access.

More detail is in [SECURITY.md](SECURITY.md).

## Deployment workflow

The repository includes separate GitHub Actions workflows for:

- [repository validation](.github/workflows/validate.yml);
- [Azure What-If](.github/workflows/dev-what-if.yml);
- [guarded deployment](.github/workflows/dev-deployment.yml).

The portfolio deployment required the correct profile, the `DEPLOY-PORTFOLIO` confirmation and an approved commit SHA.

The workflow checked the commit, ran Azure validation and What-If, and stopped if destructive changes were detected.

## Problems I had to fix

Deploying to a real subscription exposed issues that a successful Bicep build did not show:

- the original GitHub OIDC federation subject did not match the environment token;
- the deployment identity needed narrowly scoped policy and RBAC permissions;
- hard require-tag policies blocked Private DNS virtual network links;
- Azure SQL Free exposed a smaller database limit on this subscription;
- parallel subnet writes caused `AnotherOperationInProgress` errors.

I corrected the identity and policy configuration, adapted the SQL settings and serialized subnet deployment in Bicep.

## Cleanup

After verification, I removed the workload resources to stop ongoing Azure charges.

The resource group was recreated empty, and the deployment identity was kept with limited access so I can deploy the environment again later.

[Post-cleanup empty resource group](docs/evidence/portfolio-deployment/screenshots/20-post-cleanup-empty-resource-group.png)

## Repository layout

```text
.github/workflows/   validation, What-If and guarded deployment
docs/                project notes and verified deployment evidence
infra/               Bicep modules and deployment parameters
scripts/             validation and subscription readiness checks
src/                 small Node.js application
ARCHITECTURE.md      full architecture notes
SECURITY.md          security controls and access model
OPERATIONS.md        operational notes
GOVERNANCE.md        policy and governance notes
```

## Local checks

```bash
./scripts/check-repository-hygiene.sh
npm ci --prefix src
node --check src/app.js
az bicep build --file infra/main.bicep --stdout > /dev/null
```

This is a portfolio project, not a production service. The full architecture shows what is designed; the smaller portfolio profile shows what was actually deployed.

## Licence

This project is available under the [MIT Licence](LICENSE).
