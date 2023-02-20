param name string

param location string = resourceGroup().location

@description('Address prefix')
param vnetAddressPrefix string

@description('IP addresses of DNS servers to use')
param dnsServers array = []

@description('Name, addressPrefix, delegations, serviceEndpoints, routeTable, natGateway, networkSecurityGroup, privateEndpointNetworkPolicies and privateLinkServiceNetworkPolicies of the subnets')
param subnets array

param privateStorageFileDnsZoneName string = 'StorageFileDnsZone'
param privateStorageBlobDnsZoneName string = 'BlobDnsZone'
param privateStorageQueueDnsZoneName string = 'QueueDnsZone'
param privateStorageTableDnsZoneName string = 'TableDnsZone'

param virtualNetworkLinksSuffixFileStorageName string = ''
param virtualNetworkLinksSuffixBlobStorageName string = ''
param virtualNetworkLinksSuffixQueueStorageName string = ''
param virtualNetworkLinksSuffixTableStorageName string = ''

@description('id and name')
param storageAccount object

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    subnets: [for item in subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        delegations: item.delegations
        serviceEndpoints: item.serviceEndpoints
        routeTable: ((!empty(item.routeTable)) ? json('{"id":"${resourceId('Microsoft.Network/routeTables', item.routeTable)}"}') : json('null'))
        natGateway: ((!empty(item.natGateway)) ? json('{"id":"${resourceId('Microsoft.Network/natGateways', item.natGateway)}"}') : json('null'))
        networkSecurityGroup: ((!empty(item.networkSecurityGroup)) ? json('{"id":"${resourceId('Microsoft.Network/networkSecurityGroups', item.networkSecurityGroup)}"}') : json('null'))
        privateEndpointNetworkPolicies: item.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: item.privateLinkServiceNetworkPolicies
      }
    }]
  }
}

resource privateStorageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageFileDnsZoneName
  location: 'global'
  dependsOn: [
    vnet
  ]
}

resource privateStorageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageBlobDnsZoneName
  location: 'global'
  dependsOn: [
    vnet
  ]
}

resource privateStorageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageQueueDnsZoneName
  location: 'global'
  dependsOn: [
    vnet
  ]
}

resource privateStorageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageTableDnsZoneName
  location: 'global'
  dependsOn: [
    vnet
  ]
}

resource privateStorageFileDnsZoneName_virtualNetworkLinksSuffixFileStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateStorageFileDnsZone
  name: virtualNetworkLinksSuffixFileStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateStorageBlobDnsZoneName_virtualNetworkLinksSuffixBlobStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateStorageBlobDnsZone
  name: virtualNetworkLinksSuffixBlobStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateStorageQueueDnsZoneName_virtualNetworkLinksSuffixQueueStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateStorageQueueDnsZone
  name: virtualNetworkLinksSuffixQueueStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateStorageTableDnsZoneName_virtualNetworkLinksSuffixTableStorage 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateStorageTableDnsZone
  name: virtualNetworkLinksSuffixTableStorageName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateEndpointFileStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${storageAccount.name}-file-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, storageAccount.name)
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

resource privateEndpointBlobStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${storageAccount.name}-blob-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, storageAccount.name)
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateEndpointQueueStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${storageAccount.name}-queue-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, storageAccount.name)
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'queue'
          ]
        }
      }
    ]
  }
}

resource privateEndpointTableStorage 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  name: '${storageAccount.name}-table-private-endpoint'
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, storageAccount.name)
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStorageQueuePrivateLinkConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'table'
          ]
        }
      }
    ]
  }
}

resource privateEndpointFileStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpointFileStorage
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageFileDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointBlobStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpointBlobStorage
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageBlobDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointQueueStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpointQueueStorage
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageQueueDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointTableStorageName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpointTableStorage
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateStorageTableDnsZone.id
        }
      }
    ]
  }
}
