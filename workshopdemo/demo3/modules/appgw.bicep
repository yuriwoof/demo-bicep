@description('Location for all resources')
param location string = resourceGroup().location

@description('Virtual Network resource ID where Application Gateway will be deployed')
param virtualNetworkName string = 'vnet-appgw'

@description('Subnet name for Application Gateway (must be dedicated subnet)')
param subnetName string = 'default'

@description('Virtual Network IP prefix')
param vnetIPrefix string = '10.0.0.0/16'

@description('Subnet IP prefix')
param subnetIPrefix string = '10.0.0.0/24'

@description('Application Gateway name')
param applicationGatewayName string

@description('App Service FQDN (Fully Qualified Domain Name)')
param appServiceFqdn string

@description('Application Gateway SKU')
@allowed(['Standard_Small', 'Standard_Medium', 'Standard_Large', 'WAF_Medium', 'WAF_Large', 'Standard_v2', 'WAF_v2'])
param skuName string = 'Standard_v2'

@description('Application Gateway tier')
@allowed(['Standard', 'WAF', 'Standard_v2', 'WAF_v2'])
param skuTier string = 'Standard_v2'

// Variables
var gatewayIPConfigName = 'appGatewayIpConfig'
var frontendIPConfigName = 'appGatewayFrontendIP'
var frontendPortName = 'appGatewayFrontendPort'
var backendAddressPoolName = 'appServiceBackendPool'
var backendHttpSettingsName = 'appServiceBackendHttpSettings'
var httpListenerName = 'appGatewayHttpListener'
var requestRoutingRuleName = 'appServiceRule'

// Public IP configuration
var publicIPName = '${applicationGatewayName}-pip'
var publicIPAllocationMethod = 'Static'
var publicIPSku = 'Standard'

// Vitual Network

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetIPrefix
        }
      }
    ]
  }
}

// Public IP Address for Application Gateway

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIPName
  location: location
  sku: {
    name: publicIPSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

// Application Gateway

resource appgw 'Microsoft.Network/applicationGateways@2023-04-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: skuName
      tier: skuTier
    }
    gatewayIPConfigurations: [
      {
        name: gatewayIPConfigName
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIPConfigName
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: appServiceFqdn
            }
          ]
        }
      }
    ]

    // Backend HTTP Settings
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsName
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, frontendIPConfigName)
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, frontendPortName)
          }
          protocol: 'Http'
          hostNames: []
        }
      }
    ]
    requestRoutingRules: [
      {
        name: requestRoutingRuleName
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, httpListenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, backendAddressPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, backendHttpSettingsName)
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 10
    }
  }
}

// Output values

@description('Application Gateway resource ID')
output applicationGatewayId string = appgw.id

@description('Application Gateway name')
output applicationGatewayName string = appgw.name

@description('Public IP address of the Application Gateway')
output publicIpAddress string = publicIP.properties.ipAddress

@description('Application Gateway frontend URL (HTTP)')
output frontendUrlHttp string = 'http://${publicIP.properties.ipAddress}'

@description('Backend pool name')
output backendPoolName string = backendAddressPoolName
