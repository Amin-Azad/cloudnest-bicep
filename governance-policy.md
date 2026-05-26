# Governance & Azure Policy

## Objective

The goal of this phase was to implement an enterprise governance layer for the CloudNest Azure environment using Azure Policy.

This phase focuses on:

- resource compliance
- approved deployment standards
- tag governance
- cost ownership
- security guardrails
- automated remediation

---

## Governance Architecture

CloudNest uses Azure Policy at resource group scope to validate and control resources deployed into the development environment.

Current governance scope:

- Resource Group: `rg-cloudnest-dev`
- Environment: `dev`
- Policy scope: Resource group
- Enforcement model: Audit-first with selective deny enforcement

In a production enterprise environment, these policies would normally be assigned at Management Group scope so multiple subscriptions inherit the same standards.

---

## Azure Policy Strategy

CloudNest uses a staged governance rollout model.

| Policy Area | Enforcement Mode | Purpose |
|---|---|---|
| Required project tag | DoNotEnforce | Audit missing project ownership |
| Required environment tag | DoNotEnforce | Audit missing environment classification |
| Required owner tag | DoNotEnforce | Audit missing ownership metadata |
| Allowed locations | DoNotEnforce | Audit deployments outside approved regions |
| Deny public blob access | Default | Block insecure anonymous blob exposure |
| Inherit project tag | Default | Automatically add missing project tag |
| Inherit environment tag | Default | Automatically add missing environment tag |
| Inherit owner tag | Default | Automatically add missing owner tag |

---

## Audit vs Deny Strategy

CloudNest intentionally uses `DoNotEnforce` for required tag and location policies.

This allows policy compliance to be assessed without blocking active deployments.

This is a common enterprise rollout pattern:

1. Deploy policies in audit mode
2. Review non-compliant resources
3. Remediate missing configuration
4. Switch mature policies to enforcement mode

Security-sensitive policies, such as denying public blob access, are enforced immediately using `Default` mode.

---

## Tag Governance

The CloudNest resource group uses standard governance tags:

| Tag | Value | Purpose |
|---|---|---|
| project | cloudnest | Identifies the project |
| environment | dev | Identifies environment lifecycle |
| owner | amin | Identifies technical owner |

The resource group was updated with:

```bash
az group update \
  --name rg-cloudnest-dev \
  --tags project=cloudnest environment=dev owner=amin

## Remediation Tasks

Remediation tasks were created to apply missing inherited tags to existing resources.

### Remediation Tasks

| Name | Purpose |
|---|---|
| remediate-project-tag-dev | Apply missing project tag |
| remediate-environment-tag-dev | Apply missing environment tag |
| remediate-owner-tag-dev | Apply missing owner tag |

### Verification Command

```bash
az policy remediation list \
  --resource-group rg-cloudnest-dev \
  --output table
```

---

## Security Guardrail: Public Blob Access

A deny policy was assigned to prevent storage accounts from allowing anonymous public blob access.

This protects against accidental public exposure of data.

### Policy Assignment

```text
policy-deny-public-blob-dev
```

### Enforcement Mode

```text
Default
```

---

## Validation Commands

### List Policy Assignments

```bash
az policy assignment list \
  --resource-group rg-cloudnest-dev \
  --query "[].{Name:name, Enforcement:enforcementMode, Identity:identity.type}" \
  --output table
```

### List Remediation Tasks

```bash
az policy remediation list \
  --resource-group rg-cloudnest-dev \
  --output table
```

### Trigger Compliance Scan

```bash
az policy state trigger-scan \
  --resource-group rg-cloudnest-dev
```

### View Compliance Summary

```bash
az policy state summarize \
  --resource-group rg-cloudnest-dev
```

### View Resource Tags

```bash
az resource list \
  --resource-group rg-cloudnest-dev \
  --query "[].{Name:name, Type:type, Tags:tags}" \
  --output table
```