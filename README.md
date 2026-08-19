# CloudNest

CloudNest is a personal Azure portfolio project built to demonstrate a small web platform using Bicep, GitHub Actions and a Node.js application.

The repository is being rebuilt before its next Azure deployment. It should not be treated as a production system or as evidence of a currently running environment.

## Current baseline

The repository currently contains:

- modular Bicep for networking, App Service, Storage, Key Vault, Azure SQL, Front Door, monitoring, alerts, autoscaling and policy
- a primary App Service design in West Europe and a secondary App Service design in Sweden Central
- a primary staging-slot definition
- a small Express application that currently serves only `GET /`
- local and pull-request validation that does not require Azure credentials
- sanitized notes from an earlier deployment completed in May 2026

The current Bicep still needs infrastructure and security corrections. In particular, the rebuild must verify private SQL connectivity, Key Vault access, App Service origin restrictions, Front Door failover, application routes and end-to-end cleanup.

## Historical deployment

An earlier version was deployed to Azure and included two App Services, a staging slot, Front Door, WAF, Storage and Key Vault private endpoints, monitoring, alerts, autoscaling and policy assignments.

That deployment did not provide enough evidence for several claims in the original documentation. Its remaining records are therefore labelled historical and do not represent the current deployment state. Sensitive Azure identifiers and obsolete public endpoints have been removed.

- [Historical validation summary](outputs/validation-output.txt)
- [Historical infrastructure workflow](screenshots/historical-infrastructure-workflow.png)
- [Historical application workflow](screenshots/historical-application-workflow.png)

## Rebuild target

The next development deployment is intended to demonstrate:

1. Bicep validation and Azure What-If through GitHub Actions and OIDC.
2. A guarded manual deployment to a protected GitHub environment.
3. Application deployment through a primary staging slot.
4. Managed Identity access to Blob Storage and Key Vault.
5. Azure SQL credentials protected by Key Vault for this version.
6. Private endpoints and private DNS for Storage, Key Vault and SQL.
7. Front Door access with WAF, origin restrictions and regional application failover.
8. Application, monitoring, alert and cleanup evidence.

Passwordless Azure SQL, database disaster recovery and storage disaster recovery remain future improvements unless they are implemented and tested during the rebuild.

## Repository layout

```text
.
├── .github/
│   ├── dependabot.yml
│   └── workflows/validate.yml
├── docs/                    Historical and supporting notes
├── infra/
│   ├── main.bicep           Current orchestration file
│   └── modules/             Focused Bicep modules
├── outputs/                 Sanitized historical summaries
├── screenshots/             Sanitized historical images
├── scripts/                 Local validation scripts
└── src/                     Node.js application
```

## Local checks

```bash
./scripts/check-repository-hygiene.sh
npm ci --prefix src
node --check src/app.js
az bicep build --file infra/main.bicep --stdout > /dev/null
```

The GitHub validation workflow also checks Bicep formatting and uses pinned action and Bicep versions. It has read-only repository permission and no Azure login or deployment step.

## Documentation status

`ARCHITECTURE.md`, `OPERATIONS.md`, `GOVERNANCE.md` and the notes under `docs/` describe parts of the earlier implementation. They are retained as historical working notes and will be rewritten after the next deployment and cleanup evidence is complete.

## Licence

This project is available under the [MIT Licence](LICENSE).
