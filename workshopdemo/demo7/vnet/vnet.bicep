@description('Name of the virtual network')
param vnetName string

@description('IP address space for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('Name of the subnet within the virtual network')
param subnetName string = 'default'

@description('IP address prefix for the subnet')
param subnetPrefix string = '10.0.0.0/24'

@description('location for the virtual network')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

// Outputs
output vnetName string = vnet.name
output vnetId string = vnet.id
