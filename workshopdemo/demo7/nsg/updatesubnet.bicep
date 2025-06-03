@description('Name of the existing Virtual Network')
param vnetName string

@description('Name of the existing subnet to associate with the NSG')
param subnetName string

@description('Properties to update for the subnet')
param subnetProperties object

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' = {
  parent: vnet
  name: subnetName
  properties: subnetProperties
}
