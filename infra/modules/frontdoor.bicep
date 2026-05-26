param environment string
param projectName string
param tags object
param webAppDefaultHostName string
param secondaryWebAppDefaultHostName string

var frontDoorProfileName = 'afd-${projectName}-${environment}'
var frontDoorEndpointName = 'fde-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var originGroupName = 'og-${projectName}-${environment}'
var primaryOriginName = 'origin-primary-${environment}'
var secondaryOriginName = 'origin-secondary-${environment}'
var routeName = 'route-${projectName}-${environment}'
var wafPolicyName = 'waf${projectName}${environment}'
var securityPolicyName = 'security-${projectName}-${environment}'

// Standard Front Door WAF policy.
// We use Standard to keep cost low for this learning/portfolio project.
resource wafPolicy 'Microsoft.Network/frontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
    }

    // Premium version note. Managed OWASP rules require Azure Front Door Premium.Premium is much more expensive, so we are NOT using it now.
    // For production later:
    // 1. Change both SKUs to 'Premium_AzureFrontDoor'
    // 2. Replace customRules with managedRules.
   /*
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: 'Block'
        }
      ]
    }
    */

    // Standard-friendly custom WAF rule.
    customRules: {
      rules: [
        {
          name: 'BlockSuspiciousQueryString'
          enabledState: 'Enabled'
          priority: 100
          ruleType: 'MatchRule'
          action: 'Block'
          matchConditions: [
            {
              matchVariable: 'QueryString'
              operator: 'Contains'
              negateCondition: false
              matchValue: [
                'select'
                'union'
                '<script'
              ]
              transforms: [
                'Lowercase'
              ]
            }
          ]
        }
      ]
    }
  }
  tags: tags
}
resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2021-06-01' = {
  name: securityPolicyName
  parent: frontDoorProfile
  dependsOn: [
    route
    wafPolicy
  ]
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: frontDoorEndpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}
resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  tags: tags
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
}

resource primaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: primaryOriginName
  parent: originGroup
  properties: {
    hostName: webAppDefaultHostName
    originHostHeader: webAppDefaultHostName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
  }
}
resource secondaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: secondaryOriginName
  parent: originGroup
  properties: {
    hostName: secondaryWebAppDefaultHostName
    originHostHeader: secondaryWebAppDefaultHostName
    httpPort: 80
    httpsPort: 443
    priority: 2
    weight: 1000
    enabledState: 'Enabled'
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: routeName
  parent: frontDoorEndpoint
  dependsOn: [
    primaryOrigin
    secondaryOrigin
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Enabled'
  }
}


output frontDoorProfileName string = frontDoorProfile.name
output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
output wafPolicyName string = wafPolicy.name
