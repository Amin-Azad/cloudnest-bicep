# Application CI/CD Pipeline

## Goal

Deploy a real application to Azure App Service using GitHub Actions CI/CD.

This phase completes the CloudNest project by demonstrating:

- Infrastructure automation
- Application deployment automation
- Staging deployment workflow
- Production slot swap deployment
- Key Vault integration with Managed Identity

---

# Architecture

GitHub Actions pipeline deploys application code to:

```text
GitHub → GitHub Actions → Azure App Service Staging Slot
```

After validation:

```text
Staging Slot → Production Slot Swap
```

---

# Technologies Used

- Azure App Service
- Deployment Slots
- GitHub Actions
- OIDC Federation
- Managed Identity
- Azure Key Vault
- Node.js
- Express.js

---

# Application Structure

```text
src/
├── app.js
├── package.json
└── package-lock.json
```

---

# Application Features

The application displays:

- Deployment environment
- Key Vault secret loading status

Example:

```html
CloudNest App is running
Environment: staging
Key Vault Secret Loaded: yes
```

---

# GitHub Actions Workflow

Workflow file:

```text
.github/workflows/app-deploy.yml
```

Pipeline steps:

1. Checkout repository
2. Setup Node.js
3. Install dependencies
4. Azure login using OIDC
5. Deploy application to staging slot

---

# Staging Slot Deployment

Application is first deployed to:

```text
staging
```

Benefits:

- Safe testing before production
- Zero downtime deployments
- Rollback capability
- Enterprise deployment pattern

---

# Production Release

Production release is performed using slot swap:

```bash
az webapp deployment slot swap \
  --resource-group rg-cloudnest-dev \
  --name webapp-cloudnest-dev-baz6xqhbrtpb6 \
  --slot staging \
  --target-slot production
```

---

# Managed Identity + Key Vault

The staging slot uses:

- System-assigned managed identity
- Key Vault Secrets User RBAC role

Application secret is loaded dynamically from Azure Key Vault:

```text
APP_SECRET
```

No secrets are stored inside the repository.

---

# Infrastructure vs Application Pipelines

## Infrastructure Pipeline

Responsible for:

- App Service
- Networking
- Front Door
- Monitoring
- Key Vault
- RBAC
- Deployment slots
- Policies
- Autoscaling

Workflow:

```text
deploy-infra.yml
```

---

## Application Pipeline

Responsible for:

- Deploying Node.js application code

Workflow:

```text
app-deploy.yml
```

---

# Portfolio Value

This phase demonstrates:

- Real-world CI/CD workflow
- Cloud-native deployment practices
- Secure secret management
- Enterprise deployment strategy
- Infrastructure as Code
- Application release automation

CloudNest now demonstrates both:

```text
Infrastructure Automation
+
Application Deployment Automation
```