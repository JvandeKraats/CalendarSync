param storageAccName string
param principalId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing =  {
  name: storageAccName
}

var blobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
resource blobDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(subscription().id, principalId, blobDataContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', blobDataContributorRoleId)
  }
}

var fileContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
resource fileContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(subscription().id, principalId, fileContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', fileContributorRoleId)
  }
}

var queueContributorRoleId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
resource queueContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(subscription().id, principalId, queueContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', queueContributorRoleId)
  }
}

var tableContributorRoleId = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
resource tableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(subscription().id, principalId, tableContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', tableContributorRoleId)
  }
}
