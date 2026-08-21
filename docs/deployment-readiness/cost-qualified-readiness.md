# Cost Qualified Readiness

This note records the earlier cost and quota check before the successful portfolio deployment.

I wanted to know if the bigger dev design was safe to try before creating Azure resources.

## Design I checked

The design at that time used North Europe as primary, Sweden Central as DR, S1 App Service, Azure SQL Basic, Front Door, Storage, Key Vault, private endpoints, Log Analytics and Application Insights.

The short test cost looked acceptable, but the Azure subscription still had a bigger problem.

## Quota result

Both the free/credit subscription and the Pay-As-You-Go subscription were checked.

The candidate regions showed `Total Regional VMs` quota of 0, so the App Service part of the design could not pass readiness.

I also checked Azure SQL availability and provider registration. The main blocker was App Service regional capacity, not the Bicep build.

Because of that I did not deploy the bigger dev profile.

## Why this is still here

I kept this note because it shows why the project later got a separate portfolio profile.

Instead of changing the full architecture only to fit one subscription, I kept the bigger design in Bicep and created a smaller profile which could actually be deployed within the available quota and cost.

That portfolio profile used Sweden Central, B1 App Service, Azure SQL Free and one region. It later passed Azure validation and What-If and was deployed successfully.

The final result is here:

- [Portfolio qualification](../evidence/portfolio-deployment/qualification-summary.md)
- [Live deployment verification](../evidence/portfolio-deployment/live-deployment-verification.md)

So the result in this document is historical. It explains an earlier blocked path, not the current state of CloudNest.
