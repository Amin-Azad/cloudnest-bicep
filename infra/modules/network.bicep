param location string
param environment string
param tags object
param projectName string
param nameSuffix string = ''

param vnetAddressPrefix string
param appSubnetAddressPrefix string
param dataSubnetAddressPrefix string
param privateEndpointSubnetAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: 'vnet-${projectName}-${environment}${nameSuffix}'
  location: location
  tags: tags

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

resource nsgApp 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'nsg-${projectName}-app-${environment}${nameSuffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-App-To-PrivateEndpoints'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Outbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: appSubnetAddressPrefix
          destinationAddressPrefix: privateEndpointSubnetAddressPrefix
        }
      }
    ]
  }
}

resource nsgData 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'nsg-${projectName}-data-${environment}${nameSuffix}'
  location: location
  tags: tags
}

resource nsgPrivate 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: 'nsg-${projectName}-private-${environment}${nameSuffix}'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-App-To-PrivateEndpoints'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: appSubnetAddressPrefix
          destinationAddressPrefix: privateEndpointSubnetAddressPrefix
        }
      }
    ]
  }
}

resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: 'snet-app'
  properties: {
    addressPrefix: appSubnetAddressPrefix
    networkSecurityGroup: {
      id: nsgApp.id
    }
    delegations: [
      {
        name: 'delegation-appservice'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource subnetData 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: 'snet-data'
  properties: {
    addressPrefix: dataSubnetAddressPrefix
    networkSecurityGroup: {
      id: nsgData.id
    }
  }
}

resource subnetPrivate 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: 'snet-private'
  properties: {
    addressPrefix: privateEndpointSubnetAddressPrefix
    privateEndpointNetworkPolicies: 'NetworkSecurityGroupEnabled'
    networkSecurityGroup: {
      id: nsgPrivate.id
    }
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output subnetAppId string = subnetApp.id
output subnetDataId string = subnetData.id
output subnetPrivateId string = subnetPrivate.id

