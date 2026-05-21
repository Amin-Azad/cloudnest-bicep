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

output vnetName string = networkModule.outputs.vnetName 
output vnetId string = networkModule.outputs.vnetId

@description('storaeg account outputs')
output storageAccountName string = storageModule.outputs.storageAccountName
output storageAccountId string = storageModule.outputs.storageAccountId
output blobContainerName string = storageModule.outputs.uploadsContainerName
output fileShareName string = storageModule.outputs.fileShareName

