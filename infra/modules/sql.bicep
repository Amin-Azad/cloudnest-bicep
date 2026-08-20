param location string
param environment string
param projectName string
param tags object
param sqlAdminLogin string

@secure()
param sqlAdminPassword string

param sqlSkuName string
param sqlSkuTier string
param sqlSkuCapacity int
param sqlMaxSizeBytes int

var suffix = uniqueString(resourceGroup().id)
var sqlServerName = 'sql-${projectName}-${environment}-${suffix}'
var sqlDatabaseName = 'sqldb-${projectName}-${environment}'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  tags: tags
  sku: {
    name: sqlSkuName
    tier: sqlSkuTier
    capacity: sqlSkuCapacity
  }
  properties: {
    maxSizeBytes: sqlMaxSizeBytes
  }
}

output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name

