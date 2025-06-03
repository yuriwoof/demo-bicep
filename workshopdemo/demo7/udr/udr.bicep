@description('Name of the route table')
param routeTableName string

@description('Name of the existing Virtual Network')
param vnetName string

@description('Name of the existing subnet to associate with the route table')
param subnetName string

@description('IP address of the virtual appliance')
param virtualApplianceIpAddress string

@description('Address prefix for the route (e.g., 0.0.0.0/0 for default route)')
param routeAddressPrefix string = '0.0.0.0/0'

@description('Name of the route')
param routeName string = 'RouteToVirtualAppliance'

@description('Tags to apply to the resource group')
param tags object = {
  Environment: 'Development'
  Project: 'Demo'
}

// Create Route Table with UDR
resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: routeTableName
  location: resourceGroup().location
  tags: tags
  properties: {
    routes: [
      {
        name: routeName
        properties: {
          addressPrefix: routeAddressPrefix
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: virtualApplianceIpAddress
        }
      }
    ]
    disableBgpRoutePropagation: false
  }
}

// Reference to existing Virtual Network
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

// Get existing subnet
resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: existingVnet
  name: subnetName
}


// Update existing subnet to associate with the route table
module updateSubnet 'updatesubnet.bicep' = {
  name: 'UpdateSubnetWithNSG'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetProperties: union(existingSubnet.properties, {
        routeTable: {
          id: routeTable.id
        }
      })
    }
}

// Outputs
output routeTableId string = routeTable.id
output routeTableName string = routeTable.name
