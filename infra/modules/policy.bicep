targetScope = 'resourceGroup'

param environment string
param allowedLocations array = [
  'westeurope'
  'northeurope'
]
param requiredTags array = [
  'project'
  'environment'
  'owner'
]

resource allowedLocationsAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-allowed-locations-${environment}'
  properties: {
    displayName: 'CloudNest - Allowed locations'
    enforcementMode: 'Default'

    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'

    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
  }
}
resource requireProjectTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-require-project-tag-${environment}'
  properties: {
    displayName: 'CloudNest - Require project tag'
    description: 'Resources must have a project tag.'
    enforcementMode: 'Default'
    policyDefinitionId: tenantResourceId(
      'Microsoft.Authorization/policyDefinitions',
      '871b6d14-10aa-478d-b590-94f262ecfa99'
    )
    parameters: {
      tagName: {
        value: 'project'
      }
    }
  }
}

resource requireEnvironmentTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-require-environment-tag-${environment}'
  properties: {
    displayName: 'CloudNest - Require environment tag'
    description: 'Resources must have an environment tag.'
    enforcementMode: 'Default'
    policyDefinitionId: tenantResourceId(
      'Microsoft.Authorization/policyDefinitions',
      '871b6d14-10aa-478d-b590-94f262ecfa99'
    )
    parameters: {
      tagName: {
        value: 'environment'
      }
    }
  }
}

resource requireOwnerTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-require-owner-tag-${environment}'
  properties: {
    displayName: 'CloudNest - Require owner tag'
    description: 'Resources must have an owner tag.'
    enforcementMode: 'Default'
    policyDefinitionId: tenantResourceId(
      'Microsoft.Authorization/policyDefinitions',
      '871b6d14-10aa-478d-b590-94f262ecfa99'
    )
    parameters: {
      tagName: {
        value: 'owner'
      }
    }
  }
}
resource denyPublicBlobAccessAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-deny-public-blob-${environment}'
  properties: {
    displayName: 'CloudNest - Deny public blob access'
    description: 'Storage accounts must not allow anonymous public blob access.'
    enforcementMode: 'Default'

    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b2982f36-99f2-4db5-8eff-283140c09693'
  }
}
resource inheritProjectTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-inherit-project-tag-${environment}'
  identity: {
    type: 'SystemAssigned'
  }
  location: resourceGroup().location
  properties: {
    displayName: 'CloudNest - Inherit project tag from resource group'
    description: 'Adds the project tag from the resource group when missing.'
    enforcementMode: 'Default'

    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070'

    parameters: {
      tagName: {
        value: 'project'
      }
    }
  }
}

resource inheritEnvironmentTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-inherit-environment-tag-${environment}'
  identity: {
    type: 'SystemAssigned'
  }
  location: resourceGroup().location
  properties: {
    displayName: 'CloudNest - Inherit environment tag from resource group'
    description: 'Adds the environment tag from the resource group when missing.'
    enforcementMode: 'Default'

    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070'

    parameters: {
      tagName: {
        value: 'environment'
      }
    }
  }
}

resource inheritOwnerTagAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'policy-inherit-owner-tag-${environment}'
  identity: {
    type: 'SystemAssigned'
  }
  location: resourceGroup().location
  properties: {
    displayName: 'CloudNest - Inherit owner tag from resource group'
    description: 'Adds the owner tag from the resource group when missing.'
    enforcementMode: 'Default'

    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ea3f2387-9b95-492a-a190-fcdc54f7b070'

    parameters: {
      tagName: {
        value: 'owner'
      }
    }
  }
}
