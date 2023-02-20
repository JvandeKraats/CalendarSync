param region string = 'westeurope'
var storageAccName = '${uniqueString(rg.id)}azfunctions'
var initFuncSubnetName = 'AzureFuncDelegatedSubnet'
var vnetName = 'virtualNetwork'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'CalendarSync'
  location: region
}

module initAzureFunction 'FuncApp.bicep' = {
  scope: resourceGroup('CalendarSync')
  name: 'Initialisation-Function'
  params: {
    storageAccountName: storageAccName
    appName: 'InitFunc'
    location: region
    vnetName: vnetName
    subnetName: initFuncSubnetName
  }
}

module vNet 'vNet.bicep' = {
  scope: rg
  name: vnetName
  params: {
    name: vnetName
    vnetAddressPrefix: '10.100.0.0/16'
    storageAccount: initAzureFunction.outputs.storageAccount
    location: region
    subnets: [
      {
        name: initFuncSubnetName
        addressPrefix: '10.100.0.0/24'
        delegations: [
          {
            name: 'AzureFunc'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
      }
      {
        name: 'StorageAccountDelegatedSubnet'
        addressPrefix: '10.100.1.0/24'
        privateLinkServiceNetworkPolicies: 'Enabled'
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}
