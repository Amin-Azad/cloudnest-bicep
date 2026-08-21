# Application CI/CD

CloudNest has a small Node.js and Express application in `src/`.

The application is intentionally simple because the main focus of this repository is Azure infrastructure. It is there so the App Service has something real to run and so application deployment can be tested later if needed.

## Current application

The current app serves a basic `GET /` route.

The repository contains:

```text
src/
├── app.js
├── package.json
└── package-lock.json
```

## Deployment slot design

The full Bicep design includes a staging slot on the primary App Service. The idea is to deploy the application to staging first and then use a slot swap for production release.

I kept this in the full design, but the staging slot was disabled in the smaller portfolio profile because I wanted to keep the real Azure deployment cheap and simple.

So I do not claim that the current portfolio deployment proved a production slot swap.

## Managed Identity and Key Vault

The App Service uses a system-assigned Managed Identity in the infrastructure design.

In the live portfolio deployment the Web App identity was created and received Key Vault Secrets User and Storage Blob Data Reader roles.

The infrastructure also supports Key Vault references for application settings so secret values do not need to be stored in the repository.

## Why this is separate

I kept application and infrastructure concerns separate because the project is mainly about cloud infrastructure.

The infrastructure deployment was the part I fully validated in Azure. The application is small on purpose and I would expand the application pipeline only if the project needed more application release testing later.
