#!/bin/bash

RESOURCE_GROUP="rg-cloudnest-dev"
PROJECT_NAME="cloudnest"
ENVIRONMENT="dev"
FRONT_DOOR_PROFILE="afd-cloudnest-dev"
ORIGIN_GROUP="og-cloudnest-dev"
AUTOSCALE_NAME="autoscale-cloudnest-dev"
OUTPUT_FILE="outputs/validation-output.txt"

PRIMARY_WEBAPP="webapp-cloudnest-dev-baz6xqhbrtpb6"

mkdir -p outputs

{
echo "CloudNest Azure Validation Report"
echo "Generated on: $(date)"
echo "Resource Group: $RESOURCE_GROUP"
echo "=============================================="
echo ""

echo "1. Resource Group"
echo "----------------------------------------------"
az group show \
  --name "$RESOURCE_GROUP" \
  --query "{Name:name, Location:location}" \
  --output table
echo ""

echo "2. App Services"
echo "----------------------------------------------"
az webapp list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Location:location, State:state, HostName:defaultHostName}" \
  --output table
echo ""

echo "3. Deployment Slots"
echo "----------------------------------------------"
az webapp deployment slot list \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PRIMARY_WEBAPP" \
  --query "[].{Slot:name, State:state, DefaultHostName:defaultHostName}" \
  --output table
echo ""

echo "4. Front Door Profile"
echo "----------------------------------------------"
az afd profile show \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE" \
  --query "{Name:name, Sku:sku.name, ProvisioningState:provisioningState}" \
  --output table
echo ""

echo "5. Front Door Endpoint"
echo "----------------------------------------------"
az afd endpoint list \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE" \
  --query "[].{Name:name, HostName:hostName, Enabled:enabledState, ProvisioningState:provisioningState}" \
  --output table
echo ""

echo "6. Front Door Origins / DR Failover"
echo "----------------------------------------------"
az afd origin list \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE" \
  --origin-group-name "$ORIGIN_GROUP" \
  --query "[].{Name:name, HostName:hostName, Priority:priority, Enabled:enabledState}" \
  --output table
echo ""

echo "7. Front Door WAF Security Policy"
echo "----------------------------------------------"
az afd security-policy list \
  --resource-group "$RESOURCE_GROUP" \
  --profile-name "$FRONT_DOOR_PROFILE" \
  --query "[].{Name:name, Type:parameters.type, ProvisioningState:provisioningState, DeploymentStatus:deploymentStatus}" \
  --output table
echo ""

echo "8. WAF Policy"
echo "----------------------------------------------"
az network front-door waf-policy list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Mode:policySettings.mode, Enabled:policySettings.enabledState, ProvisioningState:provisioningState}" \
  --output table
echo ""

echo "9. Key Vault"
echo "----------------------------------------------"
az keyvault list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Location:location, PublicNetworkAccess:properties.publicNetworkAccess}" \
  --output table
echo ""

echo "10. Private Endpoints"
echo "----------------------------------------------"
az network private-endpoint list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Location:location, GroupId:privateLinkServiceConnections[0].groupIds[0]}" \
  --output table
echo ""

echo "11. Private DNS Zones"
echo "----------------------------------------------"
az network private-dns zone list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name}" \
  --output table
echo ""

echo "12. Storage Accounts"
echo "----------------------------------------------"
az storage account list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Location:location, Kind:kind, PublicNetworkAccess:publicNetworkAccess, AllowBlobPublicAccess:allowBlobPublicAccess}" \
  --output table
echo ""

echo "13. Log Analytics Workspaces"
echo "----------------------------------------------"
az monitor log-analytics workspace list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Location:location, RetentionDays:retentionInDays}" \
  --output table
echo ""

echo "14. Application Insights"
echo "----------------------------------------------"
az monitor app-insights component show \
  --resource-group "$RESOURCE_GROUP" \
  --app "appi-cloudnest-dev" \
  --query "{Name:name, Location:location, ApplicationType:applicationType}" \
  --output table 2>/dev/null || echo "Application Insights component not found by expected name."
echo ""

echo "15. Azure Monitor Alert Rules"
echo "----------------------------------------------"
az monitor metrics alert list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Enabled:enabled, Severity:severity, WindowSize:windowSize, EvaluationFrequency:evaluationFrequency}" \
  --output table
echo ""

echo "16. Autoscale Configuration"
echo "----------------------------------------------"
az monitor autoscale show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AUTOSCALE_NAME" \
  --query "profiles[0].{Minimum:capacity.minimum, Default:capacity.default, Maximum:capacity.maximum, RuleThresholds:rules[].metricTrigger.threshold}" \
  --output jsonc
echo ""

echo "17. Azure Policy Assignments"
echo "----------------------------------------------"
az policy assignment list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, EnforcementMode:enforcementMode, Identity:identity.type}" \
  --output table
echo ""

echo "18. Azure Policy Remediation Tasks"
echo "----------------------------------------------"
az policy remediation list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, ProvisioningState:provisioningState, PolicyAssignment:policyAssignmentId}" \
  --output table
echo ""

echo "19. Resource Tags Summary"
echo "----------------------------------------------"
az resource list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[].{Name:name, Type:type, Project:tags.project, Environment:tags.environment, Owner:tags.owner, ManagedBy:tags.managedBy}" \
  --output table
echo ""

echo "Validation completed successfully."
echo "=============================================="

} | tee "$OUTPUT_FILE"