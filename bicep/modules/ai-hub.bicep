param location string
param name string
param tags object = {}
param storageAccountId string
param keyVaultId string
param containerRegistryId string
param applicationInsightsId string
param aiServicesId string
param aiServicesTarget string

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
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
  }
}

resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01' = {
  parent: aiHub
  name: '${name}-connection-AIServices'
  properties: {
    category: 'AzureOpenAI'
    target: aiServicesTarget
    authType: 'AAD'
    isSharedToAll: true
    metadata: {
      ApiVersion: '2024-02-01'
      ApiType: 'azure'
      ResourceId: aiServicesId
    }
  }
}

output id string = aiHub.id
output name string = aiHub.name
