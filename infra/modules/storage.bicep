param location string
param environment string
param tags object

param blobDeleteRetentionDays int
param containerDeleteRetentionDays int
param tierToCoolDays int
param tierToArchiveDays int

var storageAccountName = toLower('st${environment}${uniqueString(resourceGroup().id)}')
var containerName = 'uploads'
var fileShareName = 'sharedfiles'

resource storageAccount 'Microsoft.Storage/storageAccounts@2026-04-01' = {
  name: storageAccountName
  location: location
  tags: tags

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true

    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01' = {
  parent: storageAccount
  name: 'default'

  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: blobDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: containerDeleteRetentionDays
    }
    isVersioningEnabled: true
  }
}
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}
resource appDataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${storageAccount.name}/default/app-data'
  properties: {
    publicAccess: 'None'
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01' = {
  parent: storageAccount
  name: 'default'
}

resource sharedFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01' = {
  name: fileShareName
  parent: fileService
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 100
  }
}
resource lifecyclePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'blob-lifecycle-cost-optimization'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: tierToCoolDays
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: tierToArchiveDays
                }
              }
            }
          }
        }
      ]
    }
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output uploadsContainerName string = uploadsContainer.name

output fileShareName string = sharedFileShare.name
output appDataContainerName string = appDataContainer.name
