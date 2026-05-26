#!/bin/bash

RESOURCE_GROUP="rg-cloudnest-dev"
FRONT_DOOR="afd-cloudnest-dev"
AUTOSCALE_NAME="autoscale-cloudnest-dev"

OUTPUT_FILE="outputs/validation-output.txt"

echo "CloudNest Validation Report" > $OUTPUT_FILE
echo "Generated on: $(date)" >> $OUTPUT_FILE
echo "=========================================" >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Resource Group" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az group show \
  --name $RESOURCE_GROUP \
  --query "{Name:name, Location:location}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "App Services" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az webapp list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Location:location, State:state}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Deployment Slots" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az webapp deployment slot list \
  --resource-group $RESOURCE_GROUP \
  --name webapp-cloudnest-dev-baz6xqhbrtpb6 \
  --query "[].{Slot:name, State:state}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Front Door Origins" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az afd origin list \
  --resource-group $RESOURCE_GROUP \
  --profile-name $FRONT_DOOR \
  --origin-group-name "og-cloudnest-dev" \
  --query "[].{Name:name, HostName:hostName, Priority:priority}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Private Endpoints" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az network private-endpoint list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Private DNS Zones" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az network private-dns zone list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Key Vault" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az keyvault list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Location:location}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Azure Monitor Alerts" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az monitor metrics alert list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Enabled:enabled, Severity:severity}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Autoscale Configuration" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az monitor autoscale show \
  --resource-group $RESOURCE_GROUP \
  --name $AUTOSCALE_NAME \
  --query "profiles[0].{Min:capacity.minimum, Default:capacity.default, Max:capacity.maximum}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Azure Policy Assignments" >> $OUTPUT_FILE
echo "-----------------------------------------" >> $OUTPUT_FILE

az policy assignment list \
  --resource-group $RESOURCE_GROUP \
  --query "[].{Name:name, Scope:scope}" \
  --output table >> $OUTPUT_FILE

echo "" >> $OUTPUT_FILE
echo "Validation completed successfully." >> $OUTPUT_FILE

echo "Validation report saved to $OUTPUT_FILE"