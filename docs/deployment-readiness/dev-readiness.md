# Dev Deployment Readiness

CloudNest includes a guarded Azure deployment path for the dev environment. Before deployment, the repository validates the Bicep parameters, Azure resource providers, regional App Service quota and Azure SQL availability.

## Current subscription result

The Azure subscription used for portfolio testing is an enabled Free Trial subscription with the spending limit enabled.

The following European regions were checked for App Service capacity:

- North Europe
- West Europe
- Sweden Central
- Norway East
- Germany West Central
- UK South
- France Central
- Denmark East

All tested regions reported a `Total Regional VMs` App Service quota of `0`.

The planned dev regions are:

- Primary: North Europe
- DR: Sweden Central
- App Service: S1 / Standard
- Azure SQL: Basic

Azure SQL Basic is available in both planned regions, and the required resource providers are registered. However, both planned regions currently report:

- S1 App Service VM limit: 0
- Total Regional VMs limit: 0

Because of this subscription quota, the readiness script intentionally returns a failure and blocks What-If and deployment.

## Deployment safeguards

The repository now uses:

- environment-specific Bicep parameters
- Bicep parameter validation in CI
- separate GitHub OIDC identities for readiness/What-If and deployment
- a manual What-If workflow
- a manual deployment workflow requiring `DEPLOY-DEV`
- Azure subscription and provider validation
- App Service SKU and total regional quota checks
- Azure SQL regional availability checks
- GitHub `dev` environment scoping

The deployment identities currently have Reader access only.

Deployment permissions will not be enabled while the subscription fails the regional capacity checks.

## Status

Current status: **deployment blocked by Azure subscription quota**

No CloudNest infrastructure deployment was attempted after this condition was identified.
