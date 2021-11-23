param name string = 'half-vm-disconnect'
param location string = 'uksouth'
param nsgId string
param vmPrivateIPs array

var numIPsToInclude = (length(vmPrivateIPs) + 1) / 2
var ipsToInclude = take(vmPrivateIPs, numIPsToInclude)

resource nsgExperiment 'Microsoft.Chaos/experiments@2021-09-15-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    selectors: [
      {
        id: 'selector1'
        type: 'List'
        targets: [
          {
            id: '${nsgId}/providers/Microsoft.Chaos/targets/Microsoft-NetworkSecurityGroup'
            type: 'ChaosTarget'
          }
        ]
      }
    ]
    steps: [
      {
        name: 'step1'
        branches: [
          {
            name: 'branch1'
            actions: [
              {
                type: 'continuous'
                name: 'urn:csci:microsoft:networkSecurityGroup:securityRule/1.0'
                parameters: [
                  {
                    key: 'name'
                    value: 'Block_Http'
                  }
                  {
                    key: 'protocol'
                    value: 'Any'
                  }
                  {
                    key: 'sourceAddresses'
                    value: string([
                      '*'
                    ])
                  }
                  {
                    key: 'destinationAddresses'
                    value: string(ipsToInclude)
                  }
                  {
                    key: 'action'
                    value: 'Deny'
                  }
                  {
                    key: 'destinationPortRanges'
                    value: string([
                      '80'
                    ])
                  }
                  {
                    key: 'sourcePortRanges'
                    value: string([
                      '*'
                    ])
                  }
                  {
                    key: 'priority'
                    value: '100'
                  }
                  {
                    key: 'direction'
                    value: 'Inbound'
                  }
                ]
                duration: 'PT5M'
                selectorid: 'selector1'
              }
            ]
          }
        ]
      }
    ]
  }
}

module perms 'disconnect-half-vms-perms.bicep' = {
  name: 'disconnect-half-vms-perms'
  params: {
    principalId: nsgExperiment.identity.principalId
  }
  dependsOn: [
    nsgExperiment
  ]
}
