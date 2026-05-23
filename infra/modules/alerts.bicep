param location string
param environment string
param projectName string
param tags object
param webAppId string
param appServicePlanId string
param actionGroupEmail string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01'= {
  name: 'ag-${projectName}-${environment}'
  location: 'Global' 
  tags:tags
  properties:{
    groupShortName:'cloudNest'
    enabled:true
    emailReceivers:[
      {
        name:'AdminEmail'
        emailAddress:actionGroupEmail
        useCommonAlertSchema:true

      }
    ]
  }
}

resource highCpuAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-${projectName}-${environment}-high-cpu'
  location: 'Global'
  tags: tags
  properties: {
    description: 'Alert when App Service CPU percentage is high'
    severity: 3
    enabled: true
    scopes: [
      appServicePlanId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          name: 'HighCpuCondition'
          metricNamespace: 'Microsoft.Web/serverfarms'
          metricName: 'CpuPercentage'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

resource http5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'alert-${projectName}-${environment}-http-5xx'
  location: 'Global'
  tags: tags
  properties: {
    description: 'Alert when App Service has HTTP 5xx errors'
    severity: 2
    enabled: true
    scopes: [
      webAppId
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          name: 'Http5xxCondition'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Total'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

output actionGroupName string = actionGroup.name
output highCpuAlertName string = highCpuAlert.name
output http5xxAlertName string = http5xxAlert.name
