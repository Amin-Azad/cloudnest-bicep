#!/usr/bin/env bash

set -euo pipefail

PARAM_FILE="infra/environments/dev/main.bicepparam"
APP_SERVICE_API_VERSION="2026-03-15"

required_commands=(
  az
  grep
  sed
)

for command in "${required_commands[@]}"; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $command"
    exit 1
  fi
done

if ! az account show >/dev/null 2>&1; then
  echo "ERROR: Azure CLI is not authenticated."
  exit 1
fi

if [[ ! -f "$PARAM_FILE" ]]; then
  echo "ERROR: parameter file not found: $PARAM_FILE"
  exit 1
fi

if [[ -z "${CLOUDNEST_ACTION_GROUP_EMAIL:-}" ]]; then
  echo "ERROR: CLOUDNEST_ACTION_GROUP_EMAIL is not set."
  exit 1
fi

if [[ -z "${CLOUDNEST_SQL_ADMIN_PASSWORD:-}" ]]; then
  echo "ERROR: CLOUDNEST_SQL_ADMIN_PASSWORD is not set."
  exit 1
fi

echo "Validating Bicep parameters..."

if ! az bicep build-params \
  --file "$PARAM_FILE" \
  --stdout >/dev/null; then
  echo "ERROR: dev parameter file failed Bicep validation."
  exit 1
fi

echo "OK: Bicep parameters"
echo

subscription_id="$(az account show --query id --output tsv)"
subscription_name="$(az account show --query name --output tsv)"
subscription_state="$(az account show --query state --output tsv)"

primary_region="$(
  grep -E "^param location =" "$PARAM_FILE" |
    sed -E "s/.*= '([^']+)'.*/\1/"
)"

dr_region="$(
  grep -E "^param drLocation =" "$PARAM_FILE" |
    sed -E "s/.*= '([^']+)'.*/\1/"
)"

app_service_sku="$(
  grep -E "^param appServiceSkuName =" "$PARAM_FILE" |
    sed -E "s/.*= '([^']+)'.*/\1/"
)"

sql_sku="$(
  grep -E "^param sqlSkuName =" "$PARAM_FILE" |
    sed -E "s/.*= '([^']+)'.*/\1/"
)"

if [[ -z "$primary_region" ||
      -z "$dr_region" ||
      -z "$app_service_sku" ||
      -z "$sql_sku" ]]; then
  echo "ERROR: could not resolve deployment parameters."
  exit 1
fi

echo "CloudNest dev readiness"
echo "Subscription: $subscription_name"
echo "Subscription ID: $subscription_id"
echo "Subscription state: $subscription_state"
echo "Primary region: $primary_region"
echo "DR region: $dr_region"
echo "App Service SKU: $app_service_sku"
echo "SQL SKU: $sql_sku"
echo

if [[ "$subscription_state" != "Enabled" ]]; then
  echo "ERROR: Azure subscription is not Enabled."
  exit 1
fi

providers=(
  Microsoft.Web
  Microsoft.Sql
  Microsoft.Network
  Microsoft.Storage
  Microsoft.KeyVault
  Microsoft.Insights
  Microsoft.Cdn
)

echo "Checking resource providers..."

for provider in "${providers[@]}"; do
  state="$(
    az provider show \
      --namespace "$provider" \
      --query registrationState \
      --output tsv
  )"

  if [[ "$state" != "Registered" ]]; then
    echo "ERROR: $provider is not registered: $state"
    exit 1
  fi

  echo "OK: $provider"
done

echo

check_app_service_region() {
  local region="$1"
  local label="$2"
  local required_instances="$3"
  local failed=0

  echo "Checking $label App Service capacity: $region"
  echo "  Required instances: $required_instances"

  local sku_limit
  local sku_used
  local total_limit
  local total_used

  sku_limit="$(
    az rest \
      --method get \
      --url "https://management.azure.com/subscriptions/${subscription_id}/providers/Microsoft.Web/locations/${region}/usages?api-version=${APP_SERVICE_API_VERSION}" \
      --query "value[?name.localizedValue=='${app_service_sku} VMs'].limit | [0]" \
      --output tsv
  )"

  sku_used="$(
    az rest \
      --method get \
      --url "https://management.azure.com/subscriptions/${subscription_id}/providers/Microsoft.Web/locations/${region}/usages?api-version=${APP_SERVICE_API_VERSION}" \
      --query "value[?name.localizedValue=='${app_service_sku} VMs'].currentValue | [0]" \
      --output tsv
  )"

  total_limit="$(
    az rest \
      --method get \
      --url "https://management.azure.com/subscriptions/${subscription_id}/providers/Microsoft.Web/locations/${region}/usages?api-version=${APP_SERVICE_API_VERSION}" \
      --query "value[?name.localizedValue=='Total Regional VMs'].limit | [0]" \
      --output tsv
  )"

  total_used="$(
    az rest \
      --method get \
      --url "https://management.azure.com/subscriptions/${subscription_id}/providers/Microsoft.Web/locations/${region}/usages?api-version=${APP_SERVICE_API_VERSION}" \
      --query "value[?name.localizedValue=='Total Regional VMs'].currentValue | [0]" \
      --output tsv
  )"

  sku_limit="${sku_limit:-0}"
  sku_used="${sku_used:-0}"
  total_limit="${total_limit:-0}"
  total_used="${total_used:-0}"

  local sku_free=$((sku_limit - sku_used))
  local total_free=$((total_limit - total_used))

  echo "  ${app_service_sku} VMs: used=$sku_used limit=$sku_limit free=$sku_free"
  echo "  Total Regional VMs: used=$total_used limit=$total_limit free=$total_free"

  if (( sku_free < required_instances )); then
    echo "ERROR: only $sku_free free $app_service_sku instances are available in $region; $required_instances required."
    failed=1
  fi

  if (( total_free < required_instances )); then
    echo "ERROR: only $total_free Total Regional VMs are free in $region; $required_instances required."
    failed=1
  fi

  if (( failed != 0 )); then
    return 1
  fi

  echo "OK: $label App Service capacity passed."
}

check_primary_sql() {
  echo "Checking primary SQL availability: $primary_region"

  local sql_available
  sql_available="$(
    az sql db list-editions \
      --location "$primary_region" \
      --query "[?name=='${sql_sku}'].name | [0]" \
      --output tsv
  )"

  if [[ "$sql_available" != "$sql_sku" ]]; then
    echo "ERROR: Azure SQL $sql_sku is unavailable in $primary_region."
    return 1
  fi

  echo "  SQL $sql_sku: available"
  echo "OK: primary SQL availability passed."
}

readiness_failed=0

# Primary App Service autoscale permits up to two workers.
check_app_service_region "$primary_region" "primary" 2 || readiness_failed=1
echo

# DR App Service uses one worker.
check_app_service_region "$dr_region" "DR" 1 || readiness_failed=1
echo

# SQL is deployed only in the primary region.
check_primary_sql || readiness_failed=1

echo

if (( readiness_failed != 0 )); then
  echo "DEPLOYMENT BLOCKED"
  echo "CloudNest must not be deployed with the current subscription and region configuration."
  exit 1
fi

echo "READY"
echo "CloudNest dev prerequisites passed."
