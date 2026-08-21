param location string
param projectName string
param environment string
param tags object

param keyVaultId string
param storageAccountId string
param sqlServerId string

param vnetId string
@description('Whether disaster recovery networking is deployed.')
param enableDr bool = true

@description('Disaster recovery VNet resource ID. Required when enableDr is true.')
param drVnetId string = ''
param subnetPrivateId string

var blobPrivateDnsZoneName = 'privatelink.blob.${az.environment().suffixes.storage}'
var filePrivateDnsZoneName = 'privatelink.file.${az.environment().suffixes.storage}'
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var sqlPrivateDnsZoneName = 'privatelink${az.environment().suffixes.sqlServerHostname}'

var blobPrivateEndpointName = 'pep-${projectName}-blob-${environment}'
var filePrivateEndpointName = 'pep-${projectName}-file-${environment}'
var keyVaultPrivateEndpointName = 'pep-${projectName}-kv-${environment}'
var sqlPrivateEndpointName = 'pep-${projectName}-sql-${environment}'

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
  tags: tags
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
  tags: tags
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
  tags: tags
}

resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: sqlPrivateDnsZoneName
  location: 'global'
  tags: tags
}

resource blobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-${projectName}-blob-${environment}'
  parent: blobPrivateDnsZone
  location: 'global'

  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource fileDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-${projectName}-file-${environment}'
  parent: filePrivateDnsZone
  location: 'global'

  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource keyVaultDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-${projectName}-kv-${environment}'
  parent: keyVaultPrivateDnsZone
  location: 'global'

  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource sqlDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  name: 'link-${projectName}-sql-${environment}'
  parent: sqlPrivateDnsZone
  location: 'global'

  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource blobDrDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (enableDr) {
  name: 'link-${projectName}-blob-${environment}-dr'
  parent: blobPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: drVnetId
    }
  }
}

resource fileDrDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (enableDr) {
  name: 'link-${projectName}-file-${environment}-dr'
  parent: filePrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: drVnetId
    }
  }
}

resource keyVaultDrDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (enableDr) {
  name: 'link-${projectName}-kv-${environment}-dr'
  parent: keyVaultPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: drVnetId
    }
  }
}

resource sqlDrDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (enableDr) {
  name: 'link-${projectName}-sql-${environment}-dr'
  parent: sqlPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: drVnetId
    }
  }
}

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: blobPrivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id: subnetPrivateId
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
  name: filePrivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id: subnetPrivateId
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
      id: subnetPrivateId
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

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2025-05-01' = {
  name: sqlPrivateEndpointName
  location: location
  tags: tags

  properties: {
    subnet: {
      id: subnetPrivateId
    }

    privateLinkServiceConnections: [
      {
        name: 'pls-${projectName}-sql-${environment}'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
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

resource sqlPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2025-05-01' = {
  parent: sqlPrivateEndpoint
  name: 'default'

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'sql-dns-config'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZone.id
        }
      }
    ]
  }
}

output blobPrivateEndpointName string = blobPrivateEndpoint.name
output filePrivateEndpointName string = filePrivateEndpoint.name
output keyVaultPrivateEndpointName string = keyVaultPrivateEndpoint.name
output sqlPrivateEndpointName string = sqlPrivateEndpoint.name

output blobPrivateDnsZoneName string = blobPrivateDnsZone.name
output filePrivateDnsZoneName string = filePrivateDnsZone.name
output keyVaultPrivateDnsZoneName string = keyVaultPrivateDnsZone.name
output sqlPrivateDnsZoneName string = sqlPrivateDnsZone.name

