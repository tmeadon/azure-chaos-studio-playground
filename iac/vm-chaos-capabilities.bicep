param vmName string
param location string = 'uksouth'

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' existing = {
  name: vmName
}

resource vmTarget 'Microsoft.Compute/virtualMachines/providers/targets@2021-09-15-preview' = {
  name: '${vm.name}/Microsoft.Chaos/Microsoft-VirtualMachine'
  location: location
  properties: {}

  resource shutdown 'capabilities' = {
    name: 'Shutdown-1.0'
    location: location
  }

}
