#!/usr/bin/env bash

set -euo pipefail

fail() {
  echo "FAIL: $1"
  exit 1
}

sql="infra/modules/sql.bicep"
keyvault="infra/modules/keyvault.bicep"
storage="infra/modules/storage.bicep"
private_endpoints="infra/modules/private-endpoint.bicep"
app_service="infra/modules/app-service.bicep"
keyvault_rbac="infra/modules/keyvault-rbac.bicep"
storage_rbac="infra/modules/storage-rbac.bicep"
portfolio="infra/portfolio.parameters.json"

grep -q "publicNetworkAccess: 'Disabled'" "$sql" ||
  fail "SQL public network access is not disabled"

grep -q "minimalTlsVersion: '1.2'" "$sql" ||
  fail "SQL minimum TLS is not 1.2"

grep -q "publicNetworkAccess: 'Disabled'" "$keyvault" ||
  fail "Key Vault public network access is not disabled"

grep -q "enableRbacAuthorization: true" "$keyvault" ||
  fail "Key Vault RBAC authorization is not enabled"

grep -q "publicNetworkAccess: 'Disabled'" "$storage" ||
  fail "Storage public network access is not disabled"

grep -q "supportsHttpsTrafficOnly: true" "$storage" ||
  fail "Storage HTTPS-only access is not enabled"

grep -q "minimumTlsVersion: 'TLS1_2'" "$storage" ||
  fail "Storage minimum TLS is not 1.2"

grep -q "allowBlobPublicAccess: false" "$storage" ||
  fail "Anonymous blob access is not disabled"

for group_id in blob file vault sqlServer; do
  grep -q "'$group_id'" "$private_endpoints" ||
    fail "Private endpoint group is missing: $group_id"
done

grep -q "type: 'SystemAssigned'" "$app_service" ||
  fail "App Service managed identity is missing"

grep -q "httpsOnly: true" "$app_service" ||
  fail "App Service HTTPS-only is not enabled"

grep -q "ftpsState: 'Disabled'" "$app_service" ||
  fail "App Service FTPS is not disabled"

grep -q "minTlsVersion: '1.2'" "$app_service" ||
  fail "App Service minimum TLS is not 1.2"

grep -q "4633458b-17de-408a-b874-0445c86b69e6" "$keyvault_rbac" ||
  fail "Key Vault Secrets User assignment is missing"

grep -q "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1" "$storage_rbac" ||
  fail "Storage Blob Data Reader assignment is missing"

jq -e '
  .parameters.enableDr.value == false and
  .parameters.enableFrontDoor.value == false and
  .parameters.enableDeploymentSlot.value == false and
  .parameters.enableAutoscale.value == false
' "$portfolio" >/dev/null ||
  fail "Portfolio profile enables a full-design feature"

while IFS= read -r line; do
  action="${line#*uses: }"
  action="${action%% *}"

  if [[ "$action" != *@* ]]; then
    fail "GitHub Action is not pinned: $action"
  fi

  ref="${action##*@}"

  if [[ ! "$ref" =~ ^[0-9a-f]{40}$ ]]; then
    fail "GitHub Action is not pinned to a commit SHA: $action"
  fi
done < <(grep -RhsE '^[[:space:]]*uses:[[:space:]]*[^#[:space:]]+' .github/workflows)

echo "PASS: CloudNest security regressions are guarded."
