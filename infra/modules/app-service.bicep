param projectName string
param location string
param environment string
param tags object
param subNetId string
param appInsightsConnectionString string
param nameSuffix string = ''
param keyVaultName string
param appDataStorageAccountName string
param appDataContainerName string
param sqlServerFqdn string
param sqlDatabaseName string

param appServiceSkuName string
param appServiceSkuTier string
param appServiceCapacity int

var appServicePlanName = 'asp-${projectName}-${environment}${nameSuffix}'
var webAppName = 'webapp-${projectName}-${environment}${nameSuffix}-${uniqueString(resourceGroup().id, location)}'

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags

  sku: {
    name: appServiceSkuName
    tier: appServiceSkuTier
    capacity: appServiceCapacity
  }
  kind: 'linux'

  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: webAppName
  location: location
  tags: tags
  kind: 'app,linux'

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    // virtualNetworkSubnetId:subNetId
    virtualNetworkSubnetId: empty(subNetId) ? null : subNetId

    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'

      appSettings: [
        {
          name: 'ENVIRONMENT'
          value: environment
        }
        {
          name: 'APP_ENVIRONMENT'
          value: environment
        }
        {
          name: 'APP_SECRET'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/app-secret/)'
        }

        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APP_DATA_STORAGE_ACCOUNT_NAME'
          value: appDataStorageAccountName
        }
        {
          name: 'APP_DATA_CONTAINER_NAME'
          value: appDataContainerName
        }
        {
          name: 'SQL_SERVER_FQDN'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DATABASE_NAME'
          value: sqlDatabaseName
        }
      ]
    }
  }
}

output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id
output webAppName string = webApp.name
output webAppId string = webApp.id
output webAppDefaultHostName string = webApp.properties.defaultHostName
output webAppPrincipalId string = webApp.identity.principalId
