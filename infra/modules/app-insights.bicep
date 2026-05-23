param location string
param projectName string
param tags object
param environement string
param workspaceId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${projectName}-${environement}'
  location: location
  kind:'web' 
  tags:tags

  properties: {
    Application_Type:'web'
    WorkspaceResourceId: workspaceId 
  }
}
output appInsightsName string = appInsights.name
output appInsightId string = appInsights.id
output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
