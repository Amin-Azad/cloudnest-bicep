# CloudNest Operations and Monitoring

CloudNest includes monitoring, observability, CI/CD automation, autoscaling, and disaster recovery components designed to simulate operational cloud environments.

The goal of this setup is to improve visibility, deployment reliability, scalability, and platform resilience.

## Monitoring Components

CloudNest uses Azure-native monitoring services to collect telemetry, logs, and operational insights.

Main monitoring services:

- Azure Monitor
- Application Insights
- Log Analytics Workspace
- Azure Monitor Alerts
- Azure Workbooks

## Application Insights

Application Insights was configured to monitor the web application.

This provides visibility into:

- application requests
- response times
- failures
- availability
- telemetry data

## Log Analytics Workspace

Logs and telemetry are centralized inside a Log Analytics Workspace.

This allows operational data to be queried using Kusto Query Language (KQL).

Example KQL query:

```kusto
requests
| summarize RequestCount = count() by resultCode
```
## Azure Monitor Alerts

Azure Monitor alerts were configured to detect operational issues and improve platform visibility.

Configured alerts include:

- high CPU usage
- HTTP 5xx errors

These alerts help identify application and infrastructure issues faster and support proactive monitoring practices.

## Azure Workbooks

Azure Workbooks were used to create monitoring dashboards and visual operational reports.

The dashboards include:

- request trends
- error monitoring
- CPU metrics
- telemetry visualization
- operational insights

This provides centralized observability across the CloudNest environment.

## CI/CD Pipeline

CloudNest uses GitHub Actions for Infrastructure as Code deployment automation.

Deployment workflow:

1. Code is pushed to GitHub
2. GitHub Actions pipeline starts automatically
3. Bicep templates are validated
4. Azure resources are deployed automatically

OIDC federated credentials were used to avoid storing deployment secrets inside GitHub workflows.

This improves security and supports modern DevOps deployment practices.

## Autoscaling

Autoscaling rules were configured for Azure App Service.

Scaling rules help:

- optimize performance
- improve availability
- reduce unnecessary costs

CPU-based scaling rules were implemented to automatically scale application instances based on workload demand.

## Backup and Disaster Recovery

CloudNest includes backup and disaster recovery concepts to improve platform resilience.

Implemented components:

- App Service backup configuration
- Storage account protection features
- Secondary App Service deployment in Sweden Central
- Azure Front Door failover architecture design

This supports future regional failover scenarios and improves recovery planning.

## Operational Benefits

The operational architecture provides:

- centralized monitoring
- deployment automation
- scalability
- operational visibility
- resilience planning
- faster troubleshooting

## Summary

CloudNest demonstrates how Azure operational services can be combined to create a monitored, scalable, and production-style cloud platform using modern DevOps and observability practices.