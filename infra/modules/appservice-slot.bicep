param location string
param webAppName string
param slotName string = 'staging'
param tags object

resource webApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: webAppName
}

resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: webApp
  name: slotName
  location: location
  tags: tags
  properties: {
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'APP_ENVIRONMENT'
          value: slotName
        }
      ]
    }
  }
}

output slotName string = stagingSlot.name
output slotHostName string = stagingSlot.properties.defaultHostName
