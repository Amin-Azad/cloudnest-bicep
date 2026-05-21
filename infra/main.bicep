targetScope = 'resourceGroup'

param environment string = 'dev'
param location string = resourceGroup().location
param projectName string = 'cloudnest'

var storageAccountName = toLower('${take(projectName, 8)}${environment}${take(uniqueString(resourceGroup().id), 8)}')

var tags = {
  project: projectName
  environment: environment
  owner : 'Amin'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageAccountName
  location: location
  tags:tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties:{
    accessTier:'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output deployLocation string = location
