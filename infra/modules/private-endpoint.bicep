param location string
param projectName string
param environment string
param tags object
param keyVaultId string

param storageAccountId string
param vnetId string
param subnetPrivateid string

var blobPrivateDnsZoneName = 'privatelink.blob.core.windows.net'
var filePrivateDnsZoneName = 'privatelink.file.core.windows.net'

var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var keyVaultPrivateEndpointName = 'pep-${projectName}-kv-${environment}'

var blobPrivateEndpointName = 'pep-${projectName}-blob-${environment}'
var fileprivateEndpointName = 'pep-${projectName}-file-${environment}'

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01'= {
  name: blobPrivateDnsZoneName
  location:'global'
  tags:tags
}
resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01'= {
  name: filePrivateDnsZoneName
  location:'global'
  tags:tags
}
resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
  tags: tags
}
resource blobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'= {
  name: 'link${projectName}-blob-${environment}'
  parent:blobPrivateDnsZone
  location:'global'

  properties:{
    registrationEnabled:false

  virtualNetwork:{
    id:vnetId
    }
  }
}

resource fileDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01'= {
  parent:filePrivateDnsZone
  name: 'link${projectName}-file-${environment}'
  location:'global'
  
  properties:{
    registrationEnabled:false

    virtualNetwork:{  
      id:vnetId
      }
    }
}
resource keyVaultDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link${projectName}-kv-${environment}'
  location: 'global'

  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: blobPrivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id:subnetPrivateid
    }

    privateLinkServiceConnections: [
      {
        name: 'pls-${projectName}-blob-${environment}'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}
resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: fileprivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id: subnetPrivateid
    }

    privateLinkServiceConnections: [
      {
        name: 'pls-${projectName}-file-${environment}'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}
resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: keyVaultPrivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id: subnetPrivateid
    }

    privateLinkServiceConnections: [
      {
        name: 'pls-${projectName}-kv-${environment}'
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}
resource blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  parent: blobPrivateEndpoint
  name: 'default'

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-dns-config'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource filePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  parent: filePrivateEndpoint
  name: 'default'

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'file-dns-config'
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}
resource keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  parent: keyVaultPrivateEndpoint
  name: 'default'

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'kv-dns-config'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}
output blobPrivateEndpointName string = blobPrivateEndpoint.name
output filePrivateEndpointName string = filePrivateEndpoint.name

output blobPrivateDnsZoneName string = blobPrivateDnsZone.name
output filePrivateDnsZoneName string = filePrivateDnsZone.name

output keyVaultPrivateEndpointName string = keyVaultPrivateEndpoint.name
output keyVaultPrivateDnsZoneName string = keyVaultPrivateDnsZone.name
