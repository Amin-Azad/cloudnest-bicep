param projectname string
param location string 
param environment string
param tags object
param subNetId string
param storageAccountName string

var appServicePlanName = 'asp-${projectname}-${environment}'
var webAppName = 'webAppName-${projectname}-${environment}-${uniqueString(resourceGroup().id)}'

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: appServicePlanName
  location: location
  tags:tags

  sku:{
    name:'B1'
    tier:'Basic'
    capabilities:1
    
  }
  kind:'linux'

  properties: {
    reserved:true
  }
}

resource webApp 'Microsoft.Web/sites@2025-03-01'= {
  name: webAppName
  location: location
  tags:tags
  kind:'app,linux'

  identity:{
    type:'SystemAssigned'
  }
  properties:{
    serverFarmId:appServicePlan.id
    httpsOnly:true
    virtualNetworkSubnetId:subNetId

    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn:true
      ftpsState:'Disabled'
      minTlsVersion:'1.2'

      appSettings:[
        {
          name:'ENVIRONMENT'
          value:environment
        }
        {
          name:'STORAGE_ACCOUNT_NAME'
          value:storageAccountName
        }
        {
          name: 'WEBSITR_VNET_ROUTE_ALL'
          value:'1'

        }
        
      ]
    }
  }
}

output appServicePlanName string = appServicePlan.name
output webAppName string = webApp.name
output webAppDefaultHostNAme string = webApp.properties.defaultHostName
output webAppPrincipalId string = webApp.identity.principalId
