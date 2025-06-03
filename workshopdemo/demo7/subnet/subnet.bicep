@description('Name of the existing Virtual Network')
param virtualNetworkName string

@description('Name of the subnet to create')
param subnetName string

@description('Address prefix for the subnet')
param subnetAddressPrefix string = '10.0.1.0/24'

// Reference to existing Virtual Network
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
}

// Create subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: existingVnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}

// Outputs
output subnetId string = subnet.id
output subnetName string = subnet.name
output subnetAddressPrefix string = subnet.properties.addressPrefix
