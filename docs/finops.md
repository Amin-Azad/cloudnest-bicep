# Cost and FinOps

Cost became a real part of this project because the full CloudNest design was bigger than what I wanted to keep running in a personal Azure subscription.

Instead of ignoring that, I made a smaller portfolio profile for the live deployment.

## What changed for the portfolio profile

The full design keeps two regions, Front Door, staging slot and autoscale.

The portfolio profile used one region in Sweden Central, one B1 App Service and Azure SQL Free. DR, Front Door, staging slot and autoscale were disabled.

This kept the main security and networking parts of the project while reducing the parts which would create more cost.

## Cost checks before deployment

Before trying the live deployment I checked Azure pricing, regional service availability and App Service quota.

One earlier deployment path was blocked because the available subscriptions showed `Total Regional VMs` quota of 0 in the regions I was checking.

I kept that result in the repository because it explains why I did not just keep retrying the same design.

The earlier qualification notes are in [deployment readiness](deployment-readiness/cost-qualified-readiness.md).

## Cost controls in the design

The Bicep uses project and environment tags so resources can be grouped and tracked more easily.

Storage lifecycle rules are included for moving older data to cheaper tiers. Log Analytics retention is also kept limited instead of retaining logs for a long time without a reason.

Autoscale is part of the full design, but it was disabled for the portfolio profile because B1 does not fit the same autoscale design and the live test did not need it.

## Cleanup

The strongest cost control for the portfolio run was simple: I removed the workload after the deployment was verified.

I captured the screenshots and Azure details first, then cleaned the resources so they did not keep generating cost only for portfolio purposes.

The empty resource group and deployment identity were kept so another controlled deployment is still possible later.

This made more sense to me than keeping a live environment running just to have a URL on the README.
