# Dev Deployment Readiness

This note is kept as the earlier dev deployment check before the smaller portfolio profile was created.

At that time the full dev design used North Europe as primary, Sweden Central as DR, Linux App Service S1 and Azure SQL Basic.

## What happened

The readiness script checked the Azure subscription, required providers, App Service SKU capacity, Total Regional VMs quota and SQL availability.

The checked subscriptions showed `Total Regional VMs` quota of 0 in the candidate regions. Because of that I did not continue with the full dev deployment.

I treated this as a deployment qualification problem, not something to bypass by changing random SKUs until one worked.

## What I changed after this

The readiness script was improved to check remaining capacity instead of only reading the quota limit.

I also prepared a least-privilege deployment scope with `rg-cloudnest-dev`, subscription Reader for checks and resource-group scoped deployment permissions.

Later I created the smaller portfolio profile with B1 App Service and Azure SQL Free in Sweden Central. That profile passed validation and What-If and was successfully deployed.

So this document is historical readiness evidence for the bigger dev design. It is not the current deployment status.

The successful deployment is recorded here:

- [Portfolio deployment verification](../evidence/portfolio-deployment/live-deployment-verification.md)
- [Portfolio qualification](../evidence/portfolio-deployment/qualification-summary.md)
