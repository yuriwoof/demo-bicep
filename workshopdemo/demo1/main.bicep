param location string = resourceGroup().location
param storageAccountName string = 'sa${uniqueString(resourceGroup().id)}'
param storageAccountType string = 'Premium_LRS'

resource str 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
