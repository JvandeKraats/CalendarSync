//Used this guide: https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-bicep?tabs=CLI

@description('The name of the function app that you wish to create.')
param appName string

@description('Location for all resources.')
param location string = 'westeurope'

param fileShareName string = 'AzFuncFileShare'

param storageAccountName string = '${uniqueString(resourceGroup().id)}azfunctions'
param vnetName string
param subnetName string

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param storageAccountType string = 'Standard_LRS'

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName

//Needed because => "When creating a function app, you must create or link to a general-purpose Azure Storage account that supports Blob, Queue, and Table storage. 
//                   This requirement exists because Functions relies on Azure Storage for operations such as managing triggers and logging function executions."
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      bypass: 'AzureServices, Logging, Metrics'
      defaultAction: 'Allow'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

//Consumption and Premium plans are considered 'dynamic'
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    httpsOnly: true
    clientCertEnabled: true
  }
}

resource contentStorageAccountName_default_fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccountName}/default/${toLower(fileShareName)}'
  dependsOn: [
    storageAccount
  ]
}

@description('The id and name of the created Storage Account')
output storageAccount object = {
  id: storageAccount.id
  name: storageAccount.name
}
