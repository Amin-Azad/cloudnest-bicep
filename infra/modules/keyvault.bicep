param location string
param environment string
param projectName string
param tags object

var keyVaultName = toLower('kv${environment}${uniqueString(resourceGroup().id)}')

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01'= {
  name: keyVaultName
  location: location
  tags:tags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableRbacAuthorization:true
    enabledForDeployment:false
    enabledForDiskEncryption:false
    enabledForTemplateDeployment:true
    publicNetworkAccess:'Disabled'
    networkAcls:{
      bypass:'AzureServices'
      defaultAction:'Deny'
    }
  }
}
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string =keyVault.properties.vaultUri
