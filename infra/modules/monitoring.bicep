param location string
param projectName string
param environment string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01'= {
  name: 'law-${projectName}-${environment}'
  location: location
  tags:tags
  properties:{
    retentionInDays:30

    sku: {
      name:'PerGB2018'
    }
  }
}
output workspaceId string = logAnalyticsWorkspace.id
output workspace string = logAnalyticsWorkspace.name
