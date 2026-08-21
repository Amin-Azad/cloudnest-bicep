# Azure Policy

CloudNest uses Azure Policy at resource-group scope for the portfolio environment.

I kept the scope small because this is a personal project. The goal was to test useful policy controls in a real deployment, not to build a large management-group structure only for showing it.

## Policies used

The portfolio deployment used policies for allowed locations, public blob access and inherited tags.

The active policies were:

- CloudNest - Allowed locations
- CloudNest - Deny public blob access
- CloudNest - Inherit project tag from resource group
- CloudNest - Inherit environment tag from resource group
- CloudNest - Inherit owner tag from resource group

## What changed during deployment

The first version also had hard require-tag policies.

During the live deployment these blocked Private DNS virtual network link resources. This was a good example where a policy looked fine in the design but did not work well with every Azure resource type.

I removed the hard require-tag enforcement from the portfolio profile and kept the inherit-tag policies instead.

After that I registered Microsoft.PolicyInsights, triggered compliance evaluation and checked the result.

The final live environment showed 100% resource compliance, with 31 of 31 resources compliant and no non-compliant policies.

## Why I kept the result

I did not remove the failed policy idea from the project history because it was something I learned from the real deployment.

For me the useful part was not only getting a green compliance result. It was seeing how policy can also break deployment if the rule is too strict for some Azure child resources.

The screenshots and final compliance result are in [portfolio deployment verification](evidence/portfolio-deployment/live-deployment-verification.md).
