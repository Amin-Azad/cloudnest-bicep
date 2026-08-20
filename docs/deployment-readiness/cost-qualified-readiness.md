# CloudNest Cost-Qualified Deployment Readiness

## Purpose

Before attempting another Azure deployment, CloudNest was checked for cost, subscription suitability, regional service availability and App Service quota.

The goal was to avoid creating resources until the target subscription was proven suitable for the current Bicep design.

## Dev design checked

The current dev configuration uses:

- North Europe as the primary region
- Sweden Central as the DR region
- Linux App Service S1
- one primary App Service plan with autoscale from 1 to 2 workers
- one DR App Service plan with 1 worker
- Azure SQL Database Basic
- Azure Front Door Standard
- Storage, Key Vault, private endpoints, Log Analytics and Application Insights

## Cost qualification

Azure retail pricing was checked before deployment.

For the current S1 design, the known 24-hour core cost was estimated at roughly 50 DKK before low-volume storage, monitoring, networking and operation charges.

Premium v4 P0v4 was also checked as an alternative and remained within a reasonable short-test cost range.

The deployment was therefore considered affordable for a short controlled validation run.

No infrastructure was deployed as part of this cost check.

## Subscription qualification

Two Azure subscriptions were checked.

### Free / credit subscription

- subscription state: Enabled
- App Service P0v4 quota was visible in North Europe, Germany West Central and Norway East
- Total Regional VMs quota remained 0 in the checked regions

### Pay-As-You-Go subscription

- subscription state: Enabled
- quota ID confirmed as PayAsYouGo_2014-09-01
- spending limit: Off
- App Service Premium v4 quota was visible in several regions
- Total Regional VMs quota remained 0 in the checked regions

## Regional readiness result

The readiness script was updated to check available quota rather than quota limits alone.

It now validates:

- current App Service usage
- SKU quota limit
- remaining SKU capacity
- Total Regional VMs usage and remaining capacity
- two workers for the primary App Service because autoscale can reach 2
- one worker for the DR App Service
- Azure SQL availability only in the primary region
- Microsoft.Cdn registration for Azure Front Door

The Pay-As-You-Go readiness run showed:

- North Europe: App Service deployment blocked by Total Regional VMs quota of 0
- Sweden Central: App Service deployment blocked by Total Regional VMs quota of 0
- Azure SQL Basic: available in North Europe
- all providers checked by the readiness script were registered after Microsoft.Cdn was added to the validation

A separate quota inspection of the free / credit subscription also showed Total Regional VMs quota of 0 in the candidate regions.

A North Europe S1 App Service quota increase was requested on the Pay-As-You-Go subscription.

## Decision

CloudNest was not deployed.

The infrastructure passed cost review but failed App Service regional quota qualification on the available Azure subscriptions.

Changing SKUs only to bypass the quota result was intentionally avoided.

The next deployment attempt should happen only after the required App Service regional quota is available, followed by:

1. readiness validation
2. least-privilege deployment scope verification
3. Azure What-If
4. guarded deployment
5. validation
6. controlled teardown

This is an expected pre-deployment control outcome rather than a deployment failure.
