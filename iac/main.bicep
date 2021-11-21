targetScope = 'subscription'

@secure()
param adminPassword string

var location = 'uksouth'
var numVMs = 2

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'chaos-playground'
  location: location
}

module net 'network.bicep' = {
  scope: rg 
  name: 'net' 
}

module lb 'lb.bicep' = {
  scope: rg
  name: 'lb'
  params: {
    name: 'lb'
  }
}

module vms 'vm.bicep' = [for item in range(0, numVMs): {
  name: 'vm${item}'
  scope: rg
  params: {
    name: 'vm${item}'
    subnetId: net.outputs.vmSubnetId 
    adminPassword: adminPassword
    lbBackendPoolId: lb.outputs.backendPoolId
  }
}]

module vmChaosCapabilities 'vm-chaos-capabilities.bicep' = [for item in range(0, numVMs): {
  name: 'vmChaosCapabilitiesVm${item}'
  scope: rg
  params: {
    vmName: vms[item].outputs.name
  }
}]

module halfShutdownExperiment 'experiments/half-vm-shutdown.bicep' = {
  scope: rg
  name: 'halfShutdownExperiment'
  params: {
    vmIds: [for item in range(0, numVMs): vms[item].outputs.id]
  }
}
