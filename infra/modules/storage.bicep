param location string
param projectName string
param environment string
param tags object

var storageAccountName = toLower('st${environment}${uniqueString(resourceGroup().id)}')
var containerName = 'uploads'
var fileShareName = 'sharedfiles'

resource storaegAccount 'Microsoft.Storage/storageAccounts@2026-04-01'= {
  name: storageAccountName
  location:location 
  tags:tags

  sku: {
    name: 'Standard_LRS'
  }

  kind:'StorageV2'
  properties:{
    accessTier:'Hot'
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
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2026-04-01'= {
  parent:storaegAccount
  name: 'default'

  properties:{
    deleteRetentionPolicy:{
      enabled:true
      days:14
    }
    containerDeleteRetentionPolicy:{
      enabled:true
      days:14
    }
    isVersioningEnabled:true
  }
}
resource uploadsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2026-04-01'= {
  parent:blobService
  name:containerName
  properties:{
    publicAccess:'None'
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2026-04-01'= {
  parent:storaegAccount
  name:'default'
}

resource sharedFIleShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2026-04-01'= {
  name: fileShareName
  parent:fileService
  properties:{
    accessTier: 'TransactionOptimized'
    shareQuota: 100
  }
}
resource lifecyclePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  name: '${storaegAccount.name}/default'
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
                  daysAfterModificationGreaterThan: 30
                }
                tierToArchive: {
                  daysAfterModificationGreaterThan: 90
                }
              }
            }
          }
        }
      ]
    }
  }
}

output storageAccountName string = storaegAccount.name
output storageAccountId string = storaegAccount.id
output uploadsContainerName string = uploadsContainer.name

output fileShareName string = sharedFIleShare.name


