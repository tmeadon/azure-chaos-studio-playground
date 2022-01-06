param name string
param location string = 'uksouth'

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${name}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2021-03-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontend'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend'
      }
    ]
    loadBalancingRules: [
      {
        name: 'http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', name, 'frontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', name, 'backend')
          }
          frontendPort: 80
          backendPort: 80
          protocol: 'Tcp'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', name, 'http')
          }
        }
      }
    ]
    probes: [
      {
        name: 'http'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

output backendPoolId string = lb.properties.backendAddressPools[0].id
output publicIp string = pip.properties.ipAddress
