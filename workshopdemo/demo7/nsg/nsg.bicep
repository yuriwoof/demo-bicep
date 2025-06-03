@description('Name of the Network Security Group')
param nsgName string

@description('Name of the existing Virtual Network')
param vnetName string

@description('Name of the existing subnet to associate with the NSG')
param subnetName string

// This should be modified by user's reuest.
@description('Security rules for the NSG')
param securityRules array = [
  {
    name: 'AllowHTTPS'
    properties: {
      description: 'Allow HTTPS traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 1000
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowHTTP'
    properties: {
      description: 'Allow HTTP traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 1001
      direction: 'Inbound'
    }
  }
  {
    name: 'DenyAllInbound'
    properties: {
      description: 'Deny all other inbound traffic'
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
    }
  }
]

@description('Tags to apply to the NSG')
param tags object = {
  Environment: 'Development'
  Project: 'Demo'
}

// Create Network Security Group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: resourceGroup().location
  tags: tags
  properties: {
    securityRules: securityRules
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

// Attach security group to the existing subnet
module updateSubnet 'updatesubnet.bicep' = {
  name: 'UpdateSubnetWithNSG'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetProperties: union(existingSubnet.properties, {
        networkSecurityGroup: {
          id: networkSecurityGroup.id
        }
      })
    }
}

// Outputs
output nsgId string = networkSecurityGroup.id
output nsgName string = networkSecurityGroup.name
