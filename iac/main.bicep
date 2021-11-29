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

module nsgChaosCapabilities 'chaos/capabilities/nsg-capabilities.bicep' = {
  scope: rg
  name: 'nsgChaosCapabilities'
  params: {
    nsgName: net.outputs.nsgName
  }
}

module halfVMDisconnectExperiment 'chaos/experiments/disconnect-half-vms.bicep' = {
  scope: rg
  name: 'halfVMDisconnectExperiment'
  params: {
    vmPrivateIPs: [for item in range(0, numVMs): '${vms[item].outputs.privateIp}/32']
    nsgId: net.outputs.nsgId
  }
}

output publicIp string = lb.outputs.publicIp
