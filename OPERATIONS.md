# Operations

CloudNest includes monitoring, alerts and a guarded deployment process. I wanted the project to show what happens after the Bicep is written, not only the resource creation part.

## Monitoring

The deployed portfolio profile used Application Insights and a Log Analytics Workspace.

Diagnostic settings were confirmed for the primary App Service, Azure SQL Database, Key Vault, Storage Blob and Storage File. These diagnostics were connected to the Log Analytics Workspace.

I also deployed an action group, a high CPU alert and an HTTP 5xx alert.

The live deployment evidence shows the diagnostic settings and alert rules before the environment was cleaned up.

## GitHub Actions

The infrastructure workflow is manual for deployment. It does not deploy automatically from a push to `main`.

For the portfolio profile the workflow requires the profile name, the confirmation text `DEPLOY-PORTFOLIO` and the exact approved commit SHA.

The workflow then signs in with OIDC, checks the Azure identity and scope, verifies the portfolio parameters, runs Azure validation and runs What-If before deployment.

If What-If finds a Delete or Replace change, the workflow stops.

This made the deployment slower than a simple automatic pipeline, but for this project I preferred a guarded path because I was working with a personal Azure subscription and wanted to control cost and changes.

## Real deployment issues

The live run showed some problems which did not appear in static validation.

The OIDC federation subject was wrong at first. The deployment identity needed some extra policy and RBAC permissions. Hard tag policies blocked Private DNS VNet link resources. Parallel subnet updates also caused `AnotherOperationInProgress` failures.

The subnet problem was fixed by serializing the writes in Bicep. The other problems were corrected without changing the deployment identity to subscription Owner.

## Autoscale and DR

Autoscale, Front Door and the secondary App Service are part of the full design, but they were disabled in the smaller portfolio deployment.

I kept them in the Bicep because they are part of the bigger architecture, but I did not claim they were live in the portfolio environment.

## Cleanup

After successful deployment and verification I removed the workload resources so they would not keep generating cost.

The empty `rg-cloudnest-dev` resource group and the least-privilege deployment setup were retained. This means the project can be deployed again later without leaving the full environment running all the time.

## Evidence

The live operation and cleanup record is here:

- [Portfolio deployment verification](docs/evidence/portfolio-deployment/live-deployment-verification.md)
- [Deployment screenshots](docs/evidence/portfolio-deployment/screenshots)
