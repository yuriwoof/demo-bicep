@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the App Service app.')
param appServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'otameshi-plan'
var applicationGatewayName = 'otameshi-appgw'

module website 'br:<registry-name>.azurecr.io/website:v1' = {
  name: 'otameshi-website'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module appgw 'br:<registry-name>.azurecr.io/appgw:v1' = {
  name: 'otameshi-appgw'
  params: {
    applicaotnGatewayName: applicationGatewayName
    appServiceFqdn: website.outputs.appServiceAppHostName
  }
}
