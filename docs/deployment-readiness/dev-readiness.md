# Dev Deployment Readiness

CloudNest has a guarded deployment path for the dev environment.

Before deployment, the repository checks:

- Bicep parameters
- Azure subscription state
- required resource providers
- available App Service SKU capacity
- available Total Regional VMs capacity
- Azure SQL availability in the primary region

The current dev design uses North Europe as primary, Sweden Central as DR, Linux App Service S1 and Azure SQL Basic.

## Current status

**Deployment blocked by Azure App Service regional quota.**

Readiness checks were performed against both a free / credit subscription and a Pay-As-You-Go subscription. The candidate regions reported `Total Regional VMs` quota of `0`, so no CloudNest infrastructure deployment was attempted.

The readiness script now checks remaining capacity using current usage and quota limits. It requires capacity for two primary App Service workers and one DR worker.

## Deployment safeguards

The repository uses:

- environment-specific Bicep parameters
- Bicep validation in CI
- separate GitHub OIDC identities for readiness/What-If and deployment
- manual What-If
- manual deployment confirmation with `DEPLOY-DEV`
- subscription and provider validation
- App Service SKU and regional capacity checks
- primary-region Azure SQL availability checks
- GitHub `dev` environment scoping

Deployment should proceed only after regional capacity qualification passes.

## Qualification record

The cost checks, subscription comparison, quota findings and deployment decision are recorded in [Cost-Qualified Deployment Readiness](cost-qualified-readiness.md).
