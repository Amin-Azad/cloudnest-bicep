using '../../main.bicep'

param projectName = 'cloudnest'
param environment = 'dev'

param location = 'northeurope'
param drLocation = 'swedencentral'

param vnetAddressPrefix = '10.10.0.0/16'
param appSubnetAddressPrefix = '10.10.1.0/24'
param dataSubnetAddressPrefix = '10.10.2.0/24'
param privateEndpointSubnetAddressPrefix = '10.10.3.0/24'

param drVnetAddressPrefix = '10.20.0.0/16'
param drAppSubnetAddressPrefix = '10.20.1.0/24'
param drDataSubnetAddressPrefix = '10.20.2.0/24'
param drPrivateEndpointSubnetAddressPrefix = '10.20.3.0/24'

param appServiceSkuName = 'S1'
param appServiceSkuTier = 'Standard'
param appServiceCapacity = 1

param sqlSkuName = 'Basic'
param sqlSkuTier = 'Basic'
param sqlSkuCapacity = 5
param sqlMaxSizeBytes = 2147483648

param blobDeleteRetentionDays = 7
param containerDeleteRetentionDays = 7
param tierToCoolDays = 30
param tierToArchiveDays = 90

param wafRateLimitThreshold = 300
param frontDoorHealthProbePath = '/'
param frontDoorHealthProbeIntervalInSeconds = 100

param actionGroupEmail = readEnvironmentVariable('CLOUDNEST_ACTION_GROUP_EMAIL')
param sqlAdminLogin = 'cloudnestadmin'
param sqlAdminPassword = readEnvironmentVariable('CLOUDNEST_SQL_ADMIN_PASSWORD')
