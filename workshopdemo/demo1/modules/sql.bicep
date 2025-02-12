param location string = resourceGroup().location
param sqlServerName string
param adminLogin string

@secure()
param adminLoginPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminLoginPassword
  }
}
