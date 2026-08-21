# CloudNest

CloudNest is a personal Azure project I made to practice how a full cloud setup works when it is not only written in Bicep but actually deployed.

The repository has two parts. The first one is the full production-style design with two regions, Front Door, WAF, App Service, SQL, private endpoints, monitoring, autoscale and policy. The second one is a smaller portfolio profile which I used for the real Azure deployment because my subscription had quota and cost limits.

## What I deployed

The portfolio profile was deployed successfully through GitHub Actions using OIDC and a guarded manual workflow.

The live deployment included B1 App Service, Azure SQL Free, VNet integration, private endpoints for SQL, Storage and Key Vault, Managed Identity, RBAC, Log Analytics, Application Insights, diagnostic settings, alerts and Azure Policy.

Azure Policy was checked after deployment and showed 100% compliance. I also captured screenshots and deployment details before removing the workload resources again to stop ongoing cost.

The full verification is here:

- [Live deployment verification](docs/evidence/portfolio-deployment/live-deployment-verification.md)
- [Deployment qualification](docs/evidence/portfolio-deployment/qualification-summary.md)
- [Deployment screenshots](docs/evidence/portfolio-deployment/screenshots)

## Full design and portfolio profile

The full Bicep design keeps the bigger architecture in the repo. It includes a primary and DR region, Front Door with WAF, App Service deployment slot and autoscale.

I did not try to pretend the small portfolio deployment was the same thing. For the live test I disabled DR, Front Door, deployment slot and autoscale, then used one B1 App Service and Azure SQL Free in Sweden Central.

This gave me a setup I could actually deploy, validate and clean up without keeping unnecessary Azure cost running.

## What I learned from the real deployment

The real deployment showed some problems which static validation did not show. I had issues with GitHub OIDC federation, Azure RBAC permissions, Azure Policy, SQL Free limits and parallel subnet deployment.

I corrected these one by one and deployed again. The subnet race condition was fixed by serializing the writes in Bicep. I also kept the deployment identity limited instead of giving subscription Owner access.

This part was important for me because it showed the difference between infrastructure that only looks correct in code and infrastructure that actually works in Azure.

## Security

The deployed portfolio profile used private endpoints for SQL, Storage and Key Vault. Public network access was disabled for these services.

The Web App used a system-assigned Managed Identity. It received Key Vault Secrets User on the Key Vault and Storage Blob Data Reader on the Storage Account.

The GitHub deployment uses OIDC, so no Azure client secret is stored in GitHub. The deployment identity is scoped mainly to `rg-cloudnest-dev` and does not have subscription Owner access.

More detail is in [SECURITY.md](SECURITY.md).

## CI/CD

The repository uses GitHub Actions for validation, What-If and guarded deployment.

For the portfolio deployment I had to choose the portfolio profile, type `DEPLOY-PORTFOLIO` and provide the exact approved commit SHA. The workflow checked that the deployed commit matched the approved commit before Azure deployment started.

It also ran Azure validation and What-If and stopped if destructive changes were found.

## Cleanup

After the successful deployment I captured the Azure and GitHub evidence, then removed the portfolio workload to stop ongoing cost.

`rg-cloudnest-dev` was recreated empty and the least-privilege deployment foundation was kept so the environment can be deployed again later.

## Repository layout

```text
.
├── .github/workflows/       validation, What-If and guarded deployment
├── docs/                    project notes and deployment evidence
├── infra/                   Bicep and deployment parameters
├── scripts/                 validation and readiness checks
├── src/                     small Node.js app
├── ARCHITECTURE.md
├── SECURITY.md
├── OPERATIONS.md
└── GOVERNANCE.md
```

## Local checks

```bash
./scripts/check-repository-hygiene.sh
npm ci --prefix src
node --check src/app.js
az bicep build --file infra/main.bicep --stdout > /dev/null
```

## Note

This is a portfolio project, not a production service. The full architecture is there to show the design, while the smaller portfolio profile is the version I actually deployed and verified in Azure.

## Licence

This project is available under the [MIT Licence](LICENSE).
