param location string
param name string
param tags object = {}

@description('Object ID of the Microsoft Entra ID user to grant Storage role assignments')
param userObjectId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output id string = storageAccount.id

resource storageAccountContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  scope: resourceGroup()
}
resource storageAccountContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storageAccount.id, userObjectId, storageAccountContributorRole.id)
  scope: storageAccount
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageAccountContributorRole.id
    principalType: 'User'
  }
}

resource storageBlobDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: resourceGroup()
}
resource storageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storageAccount.id, userObjectId, storageBlobDataContributorRole.id)
  scope: storageAccount
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageBlobDataContributorRole.id
    principalType: 'User'
  }
}

resource storageFileDataPrivilegedContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  scope: resourceGroup()
}
resource storageFileDataPrivilegedContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storageAccount.id, userObjectId, storageFileDataPrivilegedContributorRole.id)
  scope: storageAccount
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageFileDataPrivilegedContributorRole.id
    principalType: 'User'
  }
}

resource storageTableDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  scope: resourceGroup()
}
resource storageTableDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(storageAccount.id, userObjectId, storageTableDataContributorRole.id)
  scope: storageAccount
  properties: {
    principalId: userObjectId
    roleDefinitionId: storageTableDataContributorRole.id
    principalType: 'User'
  }
}
