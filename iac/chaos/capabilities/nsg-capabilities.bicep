param nsgName string
param location string = 'uksouth'

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' existing = {
  name: nsgName
}

resource nsgTarget 'Microsoft.Network/networkSecurityGroups/providers/targets@2021-09-15-preview' = {
  name: '${nsg.name}/Microsoft.Chaos/Microsoft-NetworkSecurityGroup'
  location: location
  properties: {}

  resource setRules 'capabilities' = {
    name: 'SecurityRule-1.0'
    location: location
  }
}
