# Governance

CloudNest uses Azure Policy and tagging mainly to show how I would keep a small environment controlled and easier to manage.

I kept the policy scope at `rg-cloudnest-dev` because this is a portfolio project. I did not use subscription-wide policy for something this small.

## Policy

The deployed portfolio profile used these policy areas:

- allowed locations
- deny public blob access
- inherit project tag
- inherit environment tag
- inherit owner tag

The first version also had hard require-tag policies. During live deployment I found that these blocked Azure Private DNS virtual network link resources because some child resources do not behave the same way with tags.

Instead of forcing the deployment through, I changed the portfolio profile and kept the useful policy controls which worked with the actual resource types.

After registering Microsoft.PolicyInsights and running compliance evaluation, Azure reported 100% resource compliance for the live portfolio environment.

## Tags

The project uses simple tags such as project, environment, owner, costCenter and managedBy.

These are mainly there for ownership, filtering and cost tracking. I did not try to make a large enterprise tagging model for a small personal project.

## Cost control

Cost was one of the main reasons I created the smaller portfolio profile.

The full design uses more services and more than one region. The real deployment used one B1 App Service and Azure SQL Free, with DR, Front Door, staging slot and autoscale disabled.

I also removed the workload after the verification was finished instead of keeping it running only for a live URL.

## What the deployment changed

One useful lesson from this project was that governance rules also need testing against real Azure resources.

The policy definitions looked reasonable before deployment, but the hard tag requirement caused a real deployment problem. After correcting it, the final policy state was checked again and the environment reached 100% compliance.

The deployment and compliance evidence is in [portfolio deployment verification](docs/evidence/portfolio-deployment/live-deployment-verification.md).
