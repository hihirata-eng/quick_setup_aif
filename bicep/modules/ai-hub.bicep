param location string
param name string
param tags object = {}
param storageAccountId string
param keyVaultId string
param containerRegistryId string
param applicationInsightsId string
param aiServicesId string
param aiServicesTarget string

@description('Object ID of the Microsoft Entra ID user to grant Azure ML Data Scientist role')
param userObjectId string = ''

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    storageAccount: storageAccountId
    keyVault: keyVaultId
    containerRegistry: containerRegistryId
    applicationInsights: applicationInsightsId
    systemDatastoresAuthMode: 'identity'
  }
}

resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01' = {
  parent: aiHub
  name: '${name}-connection-AIServices'
  properties: {
    category: 'AIServices'
    target: aiServicesTarget
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: aiServicesId
    }
  }
}

output id string = aiHub.id
output name string = aiHub.name

// Azure ML Data Scientist role: allows access to AI Foundry workspace features
resource azureMLDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = if (userObjectId != '') {
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
  scope: resourceGroup()
}

resource azureMLDataScientistRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(aiHub.id, userObjectId, azureMLDataScientistRole.id)
  scope: aiHub
  properties: {
    principalId: userObjectId
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'User'
  }
}
