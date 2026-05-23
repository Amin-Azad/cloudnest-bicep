targetScope = 'resourceGroup'

param projectName string = 'cloudnest'
param location string = resourceGroup().location
param environment string = 'dev'



var tags = {
  project: projectName
  environment: environment
  owner: 'amin'
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
    storageAccountName: storageModule.outputs.storageAccountName
    subNetId: networkModule.outputs.subnetAppId
  }
}

module slotModule './modules/appservice-slot.bicep' = {
  name: 'slot-deployment-${environment}'
  params: {
    location: location
    webAppName: appServiceModule.outputs.webAppName
    slotName: 'staging'
    tags: tags
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
