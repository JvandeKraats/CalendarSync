param region string = 'westeurope'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'CalendarSync'
  location: region
}

module initAzureFunction 'durableFunc.bicep' = {
  scope: resourceGroup('CalendarSync')
  name: 'Initialisation Function'
}
