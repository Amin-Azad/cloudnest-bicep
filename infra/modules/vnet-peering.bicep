param primaryVnetName string
param primaryVnetId string
param drVnetName string
param drVnetId string

resource primaryVnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: primaryVnetName
}

resource drVnet 'Microsoft.Network/virtualNetworks@2025-05-01' existing = {
  name: drVnetName
}

resource primaryToDrPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-05-01' = {
  parent: primaryVnet
  name: 'peer-to-dr'
  properties: {
    remoteVirtualNetwork: {
      id: drVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource drToPrimaryPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-05-01' = {
  parent: drVnet
  name: 'peer-to-primary'
  properties: {
    remoteVirtualNetwork: {
      id: primaryVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

