param name string = 'half-vm-shutdown'
param location string = 'uksouth'
param vmIds array

var numVmsToInclude = (length(vmIds) + 1) / 2
var vmsToInclude = take(vmIds, numVmsToInclude)

resource vmShutdownExperiment 'Microsoft.Chaos/experiments@2021-09-15-preview' = {
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
        targets: [for item in vmsToInclude: {
          id: '${item}/providers/Microsoft.Chaos/targets/Microsoft-VirtualMachine'
          type: 'ChaosTarget'
        }]
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
                name: 'urn:csci:microsoft:virtualMachine:shutdown/1.0'
                parameters: [
                  {
                    key: 'abruptShutdown'
                    value: 'true'
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

module perms 'half-vm-shutdown-perms.bicep' = {
  name: 'vm-shutdown-perms'
  params: {
    principalId: vmShutdownExperiment.identity.principalId
  }
  dependsOn: [
    vmShutdownExperiment
  ]
}
