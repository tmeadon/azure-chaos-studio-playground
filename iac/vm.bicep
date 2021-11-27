param name string
param location string = 'uksouth'
param subnetId string
param adminUsername string = 'azureuser'
param lbBackendPoolId string

@secure()
param adminPassword string

resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: '${name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: lbBackendPoolId
            }
          ]
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: loadFileAsBase64('scripts/cloud-init.yml')
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${name}-os'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output name string = vm.name
output id string = vm.id
output privateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
