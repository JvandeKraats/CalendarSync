param region string = 'westeurope'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'CalendarSync'
  location: region
}

module initAzureFunction 'FuncApp.bicep' = {
  scope: resourceGroup('CalendarSync')
  name: 'Initialisation Function'
  params: {
    appName: 'InitFunc'
    location: 'westeurope'
  }
}
