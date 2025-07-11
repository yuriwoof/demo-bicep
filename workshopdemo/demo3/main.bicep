@description('The name of the App Service app.')
param appServiceAppName string = 'otameshi-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param appServicePlanSkuName string = 'F1'

var appServicePlanName = 'otameshi-plan'
var applicationGatewayName = 'otameshi-appgw'

module website './modules/website.bicep' = {
  name: 'otameshi-website'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
  }
}

module appgw './modules/appgw.bicep' = {
  name: 'otameshi-appgw'
  params: {
    applicationGatewayName: applicationGatewayName
    appServiceFqdn: website.outputs.appServiceAppHostName
  }
}
