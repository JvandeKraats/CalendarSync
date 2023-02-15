param location string = 'westeurope'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'CalendarSync'
  location: location
}