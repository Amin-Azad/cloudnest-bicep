param location string
param environment string

param tags object
param appServicePlanId string
param appServicePlanName string

resource autoscalesetting 'Microsoft.Insights/autoscalesettings@2022-10-01'= {
  name: 'autoscale-cloudnest-${environment}'
  location: location
  tags:tags 
  properties: {
    enabled:true
    targetResourceUri:appServicePlanId
    profiles: [
      {
        name:'default-sutoscale-profile'
        capacity:{
          minimum: '1'
          maximum: '2'
          default: '1'
        
        }
        rules:[
          {
            metricTrigger:{
              metricName:'CpuPercentage'
              metricResourceUri:appServicePlanId
              timeGrain:'PT1M'
              statistic:'Average'
              timeWindow:'PT10M'
              timeAggregation:'Average'
              operator:'GreaterThan'
              threshold:70
            }
            scaleAction:{
              direction:'Increase'
              type:'ChangeCount'
              value:'1'
              cooldown:'PT5M'
            }
          }
          {
            metricTrigger:{
              metricName:'CpuPercentage'
              metricResourceUri:appServicePlanId
              timeGrain:'PT1M'
              statistic:'Average'
              timeWindow:'PT10M'
              timeAggregation:'Average'
              operator:'LessThan'
              threshold:30
            }
            scaleAction:{
              direction:'Decrease'
              type:'ChangeCount'
              value:'1'
              cooldown:'PT10M'
            }
          }
        ]
      }
    ]
  }
}
