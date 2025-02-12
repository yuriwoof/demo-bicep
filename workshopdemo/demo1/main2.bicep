param location string = resourceGroup().location
param sqlServerName string
param adminLogin string

param subscriptionId string
param kvResourceGroupName string
param kvName string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
  scope: resourceGroup(subscriptionId, kvResourceGroupName)
}

module sql './modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminLogin: adminLogin
    adminLoginPassword: kv.getSecret('testpd')
  }
}
