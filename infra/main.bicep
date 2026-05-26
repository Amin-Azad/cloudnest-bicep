targetScope = 'resourceGroup'

param projectName string = 'cloudnest'
param location string = resourceGroup().location
param environment string = 'dev'
param actionGroupEmail string = 'aminazad079@gmail.com'



var tags = {
  project: projectName
  environment: environment
  owner: 'amin'
  costCenter: 'engineering'
  managedBy: 'bicep'
}

module networkModule './modules/network.bicep'= {
  name:'network-deployment-${environment}'
  params: {
    location: location
    environment: environment
    projectName: projectName
    tags: tags
  }
}

module storageModule './modules/storage.bicep'= {
  name:'storage-deployment-${environment}'
  params: {
    location:location 
    tags: tags
    environment:environment 
    projectName: projectName
  }
}
module privateEndpointModule './modules/private-endpoint.bicep' = {
  name: 'private-endpoint-deployment-${environment}'
  params: {
    location: location
    projectName: projectName
    environment: environment
    tags: tags

    storageAccountId: storageModule.outputs.storageAccountId
    keyVaultId: keyVaultModule.outputs.keyVaultId
  

    vnetId: networkModule.outputs.vnetId
    subnetPrivateid: networkModule.outputs.subnetPrivateId
  }
}

module appServiceModule './modules/app-service.bicep'= {
  name: 'app-service-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectname: projectName
    //storageAccountName: storageModule.outputs.storageAccountName
    subNetId: networkModule.outputs.subnetAppId

    appInsightsConnectionString:appInsightsModule.outputs.connectionString
    keyVaultName: keyVaultModule.outputs.keyVaultName

    //storageAccountName: storageModule.outputs.storageAccountName
    appDataStorageAccountName: storageModule.outputs.storageAccountName
    appDataContainerName: 'app-data'
  }
}
module appServiceDrModule './modules/app-service.bicep'= {
  name: 'app-service-dr-deployment-${environment}'
  params: {
    location: 'swedencentral'
    tags: tags
    environment: environment
    projectname: projectName
    keyVaultName: keyVaultModule.outputs.keyVaultName
    //storageAccountName: storageModule.outputs.storageAccountName
     appDataStorageAccountName: storageModule.outputs.storageAccountName
     appDataContainerName: 'app-data'
    

    nameSuffix: '-dr'

    //storageAccountName: storageModule.outputs.storageAccountName
    //subNetId: networkModule.outputs.subnetAppId
    subNetId: ''
    appInsightsConnectionString: appInsightsModule.outputs.connectionString
  }
}
module frontDoorModule './modules/frontdoor.bicep' = {
  name: 'frontdoor-deployment-${environment}'
  params: {
    environment: environment
    projectName: projectName
    tags: tags
    webAppDefaultHostName: appServiceModule.outputs.webAppDefaultHostNAme
    secondaryWebAppDefaultHostName:appServiceDrModule.outputs.webAppDefaultHostNAme
  }
}

module slotModule './modules/appservice-slot.bicep' = {
  name: 'slot-deployment-${environment}'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    location: location
    webAppName: appServiceModule.outputs.webAppName
    slotName: 'staging'
    tags: tags
  }
}

module monitoringModule './modules/monitoring.bicep' = {
  name:'monitoring-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectName:projectName 
  }
}

module appInsightsModule './modules/app-insights.bicep' = {
  name: 'app-insights-module-${environment}'
  params: {
    location: location
    tags: tags
    environement: environment
    projectName: projectName
    workspaceId: monitoringModule.outputs.workspaceId 
  }
}
module diagnosticsModule 'modules/diagnostics.bicep' = {
  name:'diagnostics-deployment-${environment}'
  params: {
    logAnalyticsWorkspaceId: monitoringModule.outputs.workspaceId
    webAppName:appServiceModule.outputs.webAppName 
    storageAccountName: storageModule.outputs.storageAccountName
  }
}

module alertsModule './modules/alerts.bicep' = {
  name: 'alerts-deployment-${environment}'
  params: {
    location: location
    environment: environment
    projectName: projectName
    tags: tags
    webAppId: appServiceModule.outputs.webAppId
    appServicePlanId: appServiceModule.outputs.appServicePlanId
    actionGroupEmail: actionGroupEmail
  }
}

module keyVaultModule './modules/keyvault.bicep' = {
  name:'keyvault-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectName: projectName
  }
}

module autoscaleModule './modules/autoscale.bicep' = {
  name: 'autoscale-deployment-${environment}'
  params: {
    location: location
    environment: environment
    appServicePlanId: appServiceModule.outputs.appServicePlanId
    appServicePlanName: appServiceModule.outputs.appServicePlanName
    tags: tags
    
  }
}

module policyModule './modules/policy.bicep'= {
  name:'policy-deployment-${environment}'
  params: {
    environment: environment
  }
}
module storageRbacModule './modules/storage-rbac.bicep' = {
  name: 'storage-rbac-${environment}'
  params: {
    storageAccountName: storageModule.outputs.storageAccountName
    principalId: appServiceModule.outputs.webAppPrincipalId
  }
}

output vnetName string = networkModule.outputs.vnetName 
output vnetId string = networkModule.outputs.vnetId

@description('storaeg account outputs')
output storageAccountName string = storageModule.outputs.storageAccountName
output storageAccountId string = storageModule.outputs.storageAccountId
output blobContainerName string = storageModule.outputs.uploadsContainerName
output fileShareName string = storageModule.outputs.fileShareName

@description('private endpoint')
output blobPrivateEndpointName string = privateEndpointModule.outputs.blobPrivateEndpointName
output filePrivateEndpointName string = privateEndpointModule.outputs.filePrivateEndpointName
output blobPrivateDnsZoneName string = privateEndpointModule.outputs.blobPrivateDnsZoneName
output filePrivateDnsZoneName string = privateEndpointModule.outputs.filePrivateDnsZoneName


output appServicePlanName string = appServiceModule.outputs.appServicePlanName
output webAppName string = appServiceModule.outputs.webAppName
output webdefaultHostName string = appServiceModule.outputs.webAppDefaultHostNAme
output webAppPrincipalId string = appServiceModule.outputs.webAppPrincipalId

output appInsightsName string = appInsightsModule.outputs.appInsightsName
output appInsightsId string = appInsightsModule.outputs.appInsightId


output keyVaultName string = keyVaultModule.outputs.keyVaultName
output keyVaultUri string = keyVaultModule.outputs.keyVaultUri

