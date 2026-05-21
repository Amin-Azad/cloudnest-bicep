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

output vnetName string = networkModule.outputs.vnetName 
output vnetId string = networkModule.outputs.vnetId

