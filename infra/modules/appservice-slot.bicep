param location string
param webAppName string
param slotName string = 'staging'
param keyVaultName string
param tags object

resource webApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: webAppName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: webApp
  name: slotName
  location: location
  tags: tags

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APP_ENVIRONMENT'
          value: slotName
        }
        {
          name: 'APP_SECRET'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}.vault.azure.net/secrets/app-secret/)'
        }
      ]
    }
  }
}

output slotName string = stagingSlot.name
output slotHostName string = stagingSlot.properties.defaultHostName
output slotPrincipalId string = stagingSlot.identity.principalId
