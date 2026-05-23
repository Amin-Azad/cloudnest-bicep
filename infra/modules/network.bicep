param location string 
param environment string 
param tags object
param projectName string

resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01'= {
  name: 'vnet-${projectName}-${environment}'
  location:location
  tags:tags

  properties:{
    addressSpace:{
      addressPrefixes:[
        '10.10.0.0/16'

       ]
    }
  }
}

resource nsgApp 'Microsoft.Network/networkSecurityGroups@2025-05-01'= {
  name: 'nsg-${projectName}-app-${environment}'
  location:location
  tags:tags
  }

  resource nsgData 'Microsoft.Network/networkSecurityGroups@2025-05-01'= {
    name: 'nsg-${projectName}-data-${environment}'
    location:location
    tags:tags
  }

  resource nsgPrivate 'Microsoft.Network/networkSecurityGroups@2025-05-01'= {
    name: 'nsg-${projectName}-private-${environment}'
    location:location
    tags:tags
  }

  resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: 'snet-app'
  properties: {
    addressPrefix: '10.10.1.0/24'
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
  resource subnetData 'Microsoft.Network/virtualNetworks/subnets@2025-05-01'= {
    parent:vnet
    name: 'snet-data'

    properties: {
      addressPrefix:'10.10.2.0/24'

      networkSecurityGroup:{
        id:nsgData.id
      }
    }
  }

  resource subnetPrivate 'Microsoft.Network/virtualNetworks/subnets@2025-05-01'= {
    parent: vnet
    name:'snet-private'
    
    properties:{
      addressPrefix:'10.10.3.0/24'

      networkSecurityGroup:{
        id:nsgPrivate.id
      }
    }
  }
  output vnetName string = vnet.name
  output vnetId string = vnet.id
  output subnetAppId string = subnetApp.id
  output subnetDataId string = subnetData.id
  output subnetPrivateId string = subnetPrivate.id
