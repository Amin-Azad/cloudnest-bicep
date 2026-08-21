# Infrastructure CI/CD

CloudNest uses GitHub Actions and Bicep for infrastructure validation and deployment.

The old version of this project had an automatic deployment workflow from `main`. I removed that because I did not want a personal Azure subscription deploying infrastructure from every push.

The current setup is more controlled.

## Validation

Pull requests run repository checks and Bicep validation without signing in to Azure.

The validation workflow has read-only repository permission and uses pinned action versions.

## Azure login

Azure workflows use GitHub OIDC instead of storing a client secret.

The workflow checks the tenant, subscription, service principal and expected resource-group scope after login.

## What-If and deployment

The dev path has a separate What-If workflow and a guarded manual deployment workflow.

For the portfolio profile, deployment needs `DEPLOY-PORTFOLIO` and the exact approved commit SHA. The workflow checks that the current commit is the one which was approved.

It then runs Azure deployment validation and What-If. Delete and Replace changes are treated as destructive and stop the workflow.

The final portfolio deployment was run through this workflow successfully.

## Scope

The GitHub deployment identity is not subscription Owner.

The deployment work is scoped mainly to `rg-cloudnest-dev`, with subscription Reader for the checks which need subscription information.

During the real deployment I found that policy assignment and role assignment needed a few more permissions. I added the narrow roles required for the resource group instead of giving wider access.

## Why I kept it manual

For this project I wanted the pipeline to prove that the infrastructure can be deployed, but I also wanted to avoid accidental Azure cost.

So validation is automatic, while Azure deployment needs a manual decision and checks before resources are created.

The successful deployment record is in [portfolio deployment verification](evidence/portfolio-deployment/live-deployment-verification.md).
