# CloudNest - Azure Infrastructure Platform with Bicep

CloudNest is a production-style Azure infrastructure project built using Infrastructure as Code (IaC) with Bicep.

The project demonstrates how modern Azure environments can be designed, automated, secured, monitored, and governed using Azure-native services and DevOps practices.

---

# Architecture Overview

# Architecture Overview

CloudNest includes:

- Azure Front Door with WAF
- Azure App Service with deployment slots
- Azure App Service deployment slots for staging and production workflows
- Managed Identity and Azure Key Vault
- Private Endpoints and Private DNS Zones
- Azure Monitor and Log Analytics
- Azure Workbooks and Alerts
- GitHub Actions CI/CD
- Autoscaling
- Backup and Disaster Recovery concepts
- Azure Policy and Governance controls

---

# Architecture Diagram

See the full architecture design in:

[ARCHITECTURE.md](./ARCHITECTURE.md)

---

# Core Technologies

| Area | Services |
|---|---|
| Infrastructure as Code | Bicep |
| Compute | Azure App Service |
| Networking | VNet, Private Endpoints, Private DNS |
| Security | Key Vault, Managed Identity, WAF |
| Monitoring | Azure Monitor, Log Analytics, Application Insights |
| DevOps | GitHub Actions |
| Governance | Azure Policy |
| Scalability | Autoscale |
| Resilience | Backup and DR Design |

---

# Key Features

## Infrastructure as Code

- Modular Bicep architecture
- Reusable deployment modules
- Automated Azure deployments

## Security

- Managed Identity authentication
- Azure Key Vault integration
- Private Endpoints
- Zero-trust networking approach
- Front Door WAF protection

## Monitoring and Operations

- Azure Monitor alerts
- Application Insights telemetry
- Log Analytics Workspace
- Azure Workbooks dashboards
- Operational monitoring

## CI/CD Automation

- GitHub Actions deployment pipeline
- OIDC federated authentication
- Automated Bicep deployments
- Deployment slot support for safer releases

CloudNest uses Azure App Service deployment slots to support staging and production environments.

The staging slot allows updates and validation before swapping changes into production, reducing deployment risk and downtime.

## Governance and FinOps

- Azure Policy enforcement
- Required resource tagging
- Cost optimization practices
- Autoscaling configuration

---

# Project Structure

```text
cloudnest-bicep/
│
├── infra/
│   ├── main.bicep
│   └── modules/
│
├── screenshots/
│
├── README.md
├── ARCHITECTURE.md
├── SECURITY.md
├── OPERATIONS.md
└── GOVERNANCE.md
```

---

# Documentation

| Document | Description |
|---|---|
| ARCHITECTURE.md | Infrastructure and solution architecture |
| SECURITY.md | Security and zero-trust implementation |
| OPERATIONS.md | Monitoring, CI/CD, autoscaling, and DR |
| GOVERNANCE.md | Governance, policies, and cost optimization |

---

# Operational Design

CloudNest simulates production-style Azure operational practices including:

- monitoring and observability
- deployment automation
- secure networking
- governance enforcement
- scalability planning
- disaster recovery concepts

---

# Future Improvements

Future enhancements may include:

- Terraform implementation
- AKS migration
- Blue/Green deployments
- Azure Defender integration
- Multi-region failover
- Advanced policy enforcement

---

# Learning Outcomes

This project helped strengthen practical experience with:

- Azure Infrastructure as Code
- cloud networking
- Azure security services
- monitoring and observability
- DevOps automation
- governance and operational practices

---

# Author

Amin Azad

Azure | Cloud | Infrastructure | DevOps Learning Project