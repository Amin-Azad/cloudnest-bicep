#!/usr/bin/env bash

set -euo pipefail

RESOURCE_GROUP="${CLOUDNEST_DEPLOYMENT_RESOURCE_GROUP:-rg-cloudnest-dev}"

required_variables=(
  AZURE_CLIENT_ID
  AZURE_SUBSCRIPTION_ID
  AZURE_TENANT_ID
)

for variable in "${required_variables[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    echo "ERROR: $variable is not set."
    exit 1
  fi
done

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: Azure CLI is not authenticated."
  exit 1
fi

actual_subscription_id="$(
  az account show --query id --output tsv
)"

actual_tenant_id="$(
  az account show --query tenantId --output tsv
)"

actual_identity="$(
  az account show --query user.name --output tsv
)"

actual_identity_type="$(
  az account show --query user.type --output tsv
)"

if [[ "${actual_subscription_id,,}" != "${AZURE_SUBSCRIPTION_ID,,}" ]]; then
  echo "ERROR: authenticated to unexpected Azure subscription."
  exit 1
fi

if [[ "${actual_tenant_id,,}" != "${AZURE_TENANT_ID,,}" ]]; then
  echo "ERROR: authenticated to unexpected Azure tenant."
  exit 1
fi

if [[ "$actual_identity_type" != "servicePrincipal" ]]; then
  echo "ERROR: GitHub workflow is not authenticated as a service principal."
  exit 1
fi

if [[ "${actual_identity,,}" != "${AZURE_CLIENT_ID,,}" ]]; then
  echo "ERROR: authenticated service principal does not match the expected client ID."
  exit 1
fi

resource_group_id="$(
  az group show \
    --name "$RESOURCE_GROUP" \
    --query id \
    --output tsv 2>/dev/null
)" || {
  echo "ERROR: deployment resource group does not exist: $RESOURCE_GROUP"
  exit 1
}

expected_scope="/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

if [[ "${resource_group_id,,}" != "${expected_scope,,}" ]]; then
  echo "ERROR: deployment resource group is not at the expected scope."
  exit 1
fi

echo "OK: Azure tenant"
echo "OK: Azure subscription"
echo "OK: GitHub OIDC service principal"
echo "OK: deployment resource group scope"
echo "Azure deployment scope verification passed."
