targetScope = 'subscription'

param virtualNetworkName string = 'vnet-otameshi'
param virtualNetworkAddressPrefix string = '10.0.0.0/24'
var resourceGroupName = 'rg-otameshi'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: deployment().location
}

module virtualNetwork 'modules/vnet.bicep' = {
  scope: resourceGroup
  name: 'vnet'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
  }
}
