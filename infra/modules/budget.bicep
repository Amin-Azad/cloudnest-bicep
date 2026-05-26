targetScope = 'subscription'

param budgetName string = 'budget-cloudnest-dev'
param resourceGroupName string = 'rg-cloudnest-dev'
param amount int = 50
param contactEmail string

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: '2026-05-01T00:00:00Z'
      endDate: '2027-05-01T00:00:00Z'
    }
    notifications: {
      actualCost50: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 50
        contactEmails: [
          contactEmail
        ]
      }
      actualCost80: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: [
          contactEmail
        ]
      }
      actualCost100: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: [
          contactEmail
        ]
      }
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          resourceGroupName
        ]
      }
    }
  }
}
