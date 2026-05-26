# Infrastructure CI/CD Pipeline

## Goal

Automate Azure infrastructure deployments using GitHub Actions and Bicep.

This pipeline enables Infrastructure as Code (IaC) deployments directly from GitHub.

---

# Technologies Used

- GitHub Actions
- Azure Bicep
- Azure CLI
- OIDC Federation
- Azure Resource Manager

---

# Infrastructure Pipeline Workflow

Workflow file:

```text
.github/workflows/deploy-infra.yml
```

Pipeline stages:

1. Checkout repository
2. Azure login using OIDC
3. Install Bicep
4. Validate Bicep templates
5. Execute What-If deployment
6. Deploy infrastructure to Azure

---

# Infrastructure Components

The pipeline deploys:

- Resource Groups
- Virtual Network
- Subnets
- NSGs
- Storage Accounts
- Azure Key Vault
- App Service Plan
- Azure App Service
- Deployment Slots
- Front Door
- WAF Policies
- Private Endpoints
- Private DNS Zones
- Log Analytics
- Application Insights
- Alerts
- Autoscaling
- RBAC
- Azure Policies

---

# OIDC Authentication

GitHub Actions authenticates to Azure using:

```text
OpenID Connect Federation
```

Benefits:

- No client secrets stored in GitHub
- Secure short-lived tokens
- Enterprise-grade authentication

---

# Validation and What-If

Before deployment:

```text
Validate
+
What-If
```

are executed automatically.

This helps detect infrastructure changes before deployment.

---

# Deployment Strategy

Infrastructure deployments use:

```text
Incremental ARM deployment mode
```

Benefits:

- Existing resources remain intact
- Safe iterative deployments
- Production-friendly deployment model

---

# CI/CD Flow

```text
Git Push
    ↓
GitHub Actions
    ↓
Bicep Validation
    ↓
What-If Analysis
    ↓
Azure Deployment
```

---

# Portfolio Value

This phase demonstrates:

- Infrastructure as Code
- Cloud automation
- CI/CD engineering
- Azure DevOps practices
- Secure cloud deployments
- Enterprise deployment workflows
- Automated infrastructure validation
