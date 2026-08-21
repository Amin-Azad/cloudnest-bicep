targetScope = 'resourceGroup'

param projectName string = 'cloudnest'
param location string = resourceGroup().location
param environment string = 'dev'

param vnetAddressPrefix string = '10.10.0.0/16'
param appSubnetAddressPrefix string = '10.10.1.0/24'
param dataSubnetAddressPrefix string = '10.10.2.0/24'
param privateEndpointSubnetAddressPrefix string = '10.10.3.0/24'

param drLocation string = 'swedencentral'
param drVnetAddressPrefix string = '10.20.0.0/16'
param drAppSubnetAddressPrefix string = '10.20.1.0/24'
param drDataSubnetAddressPrefix string = '10.20.2.0/24'
param drPrivateEndpointSubnetAddressPrefix string = '10.20.3.0/24'

param wafRateLimitThreshold int = 300
param frontDoorHealthProbePath string = '/'
param frontDoorHealthProbeIntervalInSeconds int = 100


@description('Deploy the secondary disaster recovery region and associated resources.')
param enableDr bool = true

@description('Deploy Azure Front Door and origin access restrictions.')
param enableFrontDoor bool = true

@description('Deploy the staging App Service slot.')
param enableDeploymentSlot bool = true

@description('Deploy App Service autoscale configuration.')
param enableAutoscale bool = true

param appServiceSkuName string = 'S1'
param appServiceSkuTier string = 'Standard'
param appServiceCapacity int = 1

param sqlSkuName string = 'Basic'
param sqlSkuTier string = 'Basic'
param sqlSkuCapacity int = 5
param sqlMaxSizeBytes int = 2147483648

param blobDeleteRetentionDays int = 14
param containerDeleteRetentionDays int = 14
param tierToCoolDays int = 30
param tierToArchiveDays int = 90
@description('Email address used by the Azure Monitor action group.')
param actionGroupEmail string

param sqlAdminLogin string = 'sqladminuser'

@secure()
param sqlAdminPassword string

var tags = {
  project: projectName
  environment: environment
  owner: 'portfolio'
  costCenter: 'engineering'
  managedBy: 'bicep'
}

module networkModule './modules/network.bicep' = {
  name: 'network-deployment-${environment}'
  params: {
    location: location
    environment: environment
    projectName: projectName
    tags: tags
    vnetAddressPrefix: vnetAddressPrefix
    appSubnetAddressPrefix: appSubnetAddressPrefix
    dataSubnetAddressPrefix: dataSubnetAddressPrefix
    privateEndpointSubnetAddressPrefix: privateEndpointSubnetAddressPrefix
  }
}

module drNetworkModule './modules/network.bicep' = if (enableDr) {
  name: 'network-dr-deployment-${environment}'
  params: {
    location: drLocation
    environment: environment
    projectName: projectName
    nameSuffix: '-dr'
    tags: tags
    vnetAddressPrefix: drVnetAddressPrefix
    appSubnetAddressPrefix: drAppSubnetAddressPrefix
    dataSubnetAddressPrefix: drDataSubnetAddressPrefix
    privateEndpointSubnetAddressPrefix: drPrivateEndpointSubnetAddressPrefix
  }
}

module vnetPeeringModule './modules/vnet-peering.bicep' = if (enableDr) {
  name: 'vnet-peering-${environment}'
  params: {
    primaryVnetName: networkModule.outputs.vnetName
    primaryVnetId: networkModule.outputs.vnetId
    // vnetPeeringModule
    drVnetName: drNetworkModule!.outputs.vnetName
    drVnetId: drNetworkModule!.outputs.vnetId
  }
}

module storageModule './modules/storage.bicep' = {
  name: 'storage-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    blobDeleteRetentionDays: blobDeleteRetentionDays
    containerDeleteRetentionDays: containerDeleteRetentionDays
    tierToCoolDays: tierToCoolDays
    tierToArchiveDays: tierToArchiveDays
  }
}
module privateEndpointModule './modules/private-endpoint.bicep' = {
  name: 'private-endpoint-deployment-${environment}'
  params: {
    location: location
    projectName: projectName
    environment: environment
    tags: tags

    storageAccountId: storageModule.outputs.storageAccountId
    keyVaultId: keyVaultModule.outputs.keyVaultId
    sqlServerId: sqlModule.outputs.sqlServerId

    vnetId: networkModule.outputs.vnetId
    enableDr: enableDr
    drVnetId: enableDr ? drNetworkModule!.outputs.vnetId : ''
    subnetPrivateId: networkModule.outputs.subnetPrivateId
  }
}

module appServiceModule './modules/app-service.bicep' = {
  name: 'app-service-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectName: projectName
    //storageAccountName: storageModule.outputs.storageAccountName
    subNetId: networkModule.outputs.subnetAppId

    appInsightsConnectionString: appInsightsModule.outputs.connectionString
    keyVaultName: keyVaultModule.outputs.keyVaultName

    //storageAccountName: storageModule.outputs.storageAccountName
    appDataStorageAccountName: storageModule.outputs.storageAccountName
    appDataContainerName: 'app-data'

    sqlServerFqdn: sqlModule.outputs.sqlServerFqdn
    sqlDatabaseName: sqlModule.outputs.sqlDatabaseName
    appServiceSkuName: appServiceSkuName
    appServiceSkuTier: appServiceSkuTier
    appServiceCapacity: appServiceCapacity
  }
}
module keyVaultRbacModule './modules/keyvault-rbac.bicep' = {
  name: 'keyvault-rbac-${environment}'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    principalId: appServiceModule.outputs.webAppPrincipalId
  }
}

module stagingKeyVaultRbacModule './modules/keyvault-rbac.bicep' = if (enableDeploymentSlot) {
  name: 'keyvault-rbac-staging-${environment}'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    principalId: slotModule!.outputs.slotPrincipalId
  }
}

module drKeyVaultRbacModule './modules/keyvault-rbac.bicep' = if (enableDr) {
  name: 'keyvault-rbac-dr-${environment}'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    principalId: appServiceDrModule!.outputs.webAppPrincipalId
  }
}

module appServiceDrModule './modules/app-service.bicep' = if (enableDr) {
  name: 'app-service-dr-deployment-${environment}'
  params: {
    location: drLocation
    tags: tags
    environment: environment
    projectName: projectName
    keyVaultName: keyVaultModule.outputs.keyVaultName
    //storageAccountName: storageModule.outputs.storageAccountName
    appDataStorageAccountName: storageModule.outputs.storageAccountName
    appDataContainerName: 'app-data'

    nameSuffix: '-dr'

    //storageAccountName: storageModule.outputs.storageAccountName
    //subNetId: networkModule.outputs.subnetAppId
    subNetId: drNetworkModule!.outputs.subnetAppId
    appInsightsConnectionString: appInsightsModule.outputs.connectionString
    sqlServerFqdn: sqlModule.outputs.sqlServerFqdn
    sqlDatabaseName: sqlModule.outputs.sqlDatabaseName
    appServiceSkuName: appServiceSkuName
    appServiceSkuTier: appServiceSkuTier
    appServiceCapacity: appServiceCapacity
  }
}
module frontDoorModule './modules/frontdoor.bicep' = if (enableFrontDoor && enableDr) {
  name: 'frontdoor-deployment-${environment}'
  params: {
    environment: environment
    projectName: projectName
    tags: tags
    webAppDefaultHostName: appServiceModule.outputs.webAppDefaultHostName
    secondaryWebAppDefaultHostName: appServiceDrModule!.outputs.webAppDefaultHostName
    wafRateLimitThreshold: wafRateLimitThreshold
    healthProbePath: frontDoorHealthProbePath
    healthProbeIntervalInSeconds: frontDoorHealthProbeIntervalInSeconds
  }
}

module primaryOriginSecurityModule './modules/app-service-origin-security.bicep' = if (enableFrontDoor && enableDr) {
  name: 'origin-security-primary-${environment}'
  params: {
    webAppName: appServiceModule.outputs.webAppName
    frontDoorId: frontDoorModule!.outputs.frontDoorId
  }
}

module secondaryOriginSecurityModule './modules/app-service-origin-security.bicep' = if (enableFrontDoor && enableDr) {
  name: 'origin-security-secondary-${environment}'
  params: {
    webAppName: appServiceDrModule!.outputs.webAppName
    frontDoorId: frontDoorModule!.outputs.frontDoorId
  }
}

module slotModule './modules/appservice-slot.bicep' = if (enableDeploymentSlot) {
  name: 'slot-deployment-${environment}'
  params: {
    keyVaultName: keyVaultModule.outputs.keyVaultName
    location: location
    webAppName: appServiceModule.outputs.webAppName
    slotName: 'staging'
    tags: tags
  }
}

module monitoringModule './modules/monitoring.bicep' = {
  name: 'monitoring-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectName: projectName
  }
}

module appInsightsModule './modules/app-insights.bicep' = {
  name: 'app-insights-module-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
    projectName: projectName
    workspaceId: monitoringModule.outputs.workspaceId
  }
}
module diagnosticsModule 'modules/diagnostics.bicep' = {
  name: 'diagnostics-deployment-${environment}'
  params: {
    logAnalyticsWorkspaceId: monitoringModule.outputs.workspaceId

    primaryWebAppName: appServiceModule.outputs.webAppName

    enableDr: enableDr
    secondaryWebAppName: enableDr ? appServiceDrModule!.outputs.webAppName : ''

    storageAccountName: storageModule.outputs.storageAccountName
    keyVaultName: keyVaultModule.outputs.keyVaultName
    sqlServerName: sqlModule.outputs.sqlServerName
    sqlDatabaseName: sqlModule.outputs.sqlDatabaseName

    enableFrontDoor: enableFrontDoor && enableDr
    frontDoorProfileName: enableFrontDoor && enableDr
  ? frontDoorModule!.outputs.frontDoorProfileName
  : ''
  }
}

module alertsModule './modules/alerts.bicep' = {
  name: 'alerts-deployment-${environment}'
  params: {
    environment: environment
    projectName: projectName
    tags: tags
    webAppId: appServiceModule.outputs.webAppId
    appServicePlanId: appServiceModule.outputs.appServicePlanId
    actionGroupEmail: actionGroupEmail
  }
}

module keyVaultModule './modules/keyvault.bicep' = {
  name: 'keyvault-deployment-${environment}'
  params: {
    location: location
    tags: tags
    environment: environment
  }
}

module autoscaleModule './modules/autoscale.bicep' = if (enableAutoscale) {
  name: 'autoscale-deployment-${environment}'
  params: {
    location: location
    environment: environment
    appServicePlanId: appServiceModule.outputs.appServicePlanId
    tags: tags
  }
}

module policyModule './modules/policy.bicep' = {
  name: 'policy-deployment-${environment}'
  params: {
    environment: environment
  }
}
module storageRbacModule './modules/storage-rbac.bicep' = {
  name: 'storage-rbac-${environment}'
  params: {
    storageAccountName: storageModule.outputs.storageAccountName
    principalId: appServiceModule.outputs.webAppPrincipalId
  }
}
module drStorageRbacModule './modules/storage-rbac.bicep' = if (enableDr) {
  name: 'storage-rbac-dr-${environment}'
  params: {
    storageAccountName: storageModule.outputs.storageAccountName
    principalId: appServiceDrModule!.outputs.webAppPrincipalId
  }
}
module sqlModule './modules/sql.bicep' = {
  name: 'sql-deployment-${environment}'
  params: {
    location: location
    environment: environment
    projectName: projectName
    tags: tags
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
    sqlSkuName: sqlSkuName
    sqlSkuTier: sqlSkuTier
    sqlSkuCapacity: sqlSkuCapacity
    sqlMaxSizeBytes: sqlMaxSizeBytes
  }
}

output vnetName string = networkModule.outputs.vnetName
output vnetId string = networkModule.outputs.vnetId

@description('storage account outputs')
output storageAccountName string = storageModule.outputs.storageAccountName
output storageAccountId string = storageModule.outputs.storageAccountId
output blobContainerName string = storageModule.outputs.uploadsContainerName
output fileShareName string = storageModule.outputs.fileShareName

@description('private endpoint')
output blobPrivateEndpointName string = privateEndpointModule.outputs.blobPrivateEndpointName
output filePrivateEndpointName string = privateEndpointModule.outputs.filePrivateEndpointName
output blobPrivateDnsZoneName string = privateEndpointModule.outputs.blobPrivateDnsZoneName
output filePrivateDnsZoneName string = privateEndpointModule.outputs.filePrivateDnsZoneName

output appServicePlanName string = appServiceModule.outputs.appServicePlanName
output webAppName string = appServiceModule.outputs.webAppName
output webdefaultHostName string = appServiceModule.outputs.webAppDefaultHostName
output webAppPrincipalId string = appServiceModule.outputs.webAppPrincipalId

output appInsightsName string = appInsightsModule.outputs.appInsightsName
output appInsightsId string = appInsightsModule.outputs.appInsightId

output keyVaultName string = keyVaultModule.outputs.keyVaultName
output keyVaultUri string = keyVaultModule.outputs.keyVaultUri

output sqlServerName string = sqlModule.outputs.sqlServerName
output sqlServerFqdn string = sqlModule.outputs.sqlServerFqdn
output sqlDatabaseName string = sqlModule.outputs.sqlDatabaseName

