param webAppName string
param frontDoorId string

resource webApp 'Microsoft.Web/sites@2025-03-01' existing = {
  name: webAppName
}

resource webConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webApp
  name: 'web'

  properties: {
    ipSecurityRestrictions: [
      {
        name: 'Allow-Azure-Front-Door'
        description: 'Allow traffic only from this Azure Front Door profile.'
        priority: 100
        action: 'Allow'
        ipAddress: 'AzureFrontDoor.Backend'
        tag: 'ServiceTag'
        headers: {
          'x-azure-fdid': [
            frontDoorId
          ]
        }
      }
    ]

    ipSecurityRestrictionsDefaultAction: 'Deny'

    scmIpSecurityRestrictionsUseMain: false
    scmIpSecurityRestrictionsDefaultAction: 'Deny'
  }
}
