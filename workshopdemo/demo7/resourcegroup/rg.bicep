@description('Name of the resource group to create')
param resourceGroupName string

@description('Location for the resource group. Choose from the following locations: japaneast, japanwest, eastus, eastus2, westus, westus2, centralus.')
@allowed([
  'japaneast'
  'japanwest'
  'eastus'
  'eastus2'
  'westus'
  'westus2'
  'centralus'
])
param location string = 'japaneast'

@description('Tags to apply to the resource group')
param tags object = {
  Environment: 'Development'
  Project: 'Demo'
}

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Outputs
output resourceGroupName string = resourceGroup.name
output resourceGroupId string = resourceGroup.id
output resourceGroupLocation string = resourceGroup.location
