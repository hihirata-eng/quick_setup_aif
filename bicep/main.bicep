var location = resourceGroup().location

@description('Prefix for all resource names (3-8 lowercase alphanumeric characters)')
@minLength(3)
@maxLength(8)
param prefix string = 'aif'

@description('gpt-5.5 をデプロイする (2026-04-24) - 最新・最高性能')
param deployGpt55 bool = false

@description('gpt-5.4 をデプロイする (2026-03-05) - 高性能・推論対応 ★デフォルト')
param deployGpt54 bool = true

@description('gpt-5.4-pro をデプロイする (2026-03-05) - プロ版')
param deployGpt54pro bool = false

@description('gpt-5.4-mini をデプロイする (2026-03-17) - 軽量版')
param deployGpt54mini bool = false

@description('gpt-5.4-nano をデプロイする (2026-03-17) - 超軽量版')
param deployGpt54nano bool = false

@description('gpt-5.3-codex をデプロイする (2026-02-24) - コーディング特化')
param deployGpt53codex bool = false

@description('gpt-5.2 をデプロイする (2025-12-11)')
param deployGpt52 bool = false

@description('gpt-5.2-codex をデプロイする (2026-01-14) - コーディング特化')
param deployGpt52codex bool = false

@description('Tokens per minute capacity per model (in thousands)')
@minValue(1)
@maxValue(100)
param gptDeploymentCapacity int = 10

var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var tags = {
  project: 'quick-setup-aif'
  createdBy: 'bicep'
}

var names = {
  openai: '${prefix}-aoai-${uniqueSuffix}'
  storage: '${prefix}st${uniqueSuffix}'
  keyVault: '${prefix}-kv-${uniqueSuffix}'
  containerRegistry: '${prefix}acr${uniqueSuffix}'
  appInsights: '${prefix}-appi-${uniqueSuffix}'
  aiHub: '${prefix}-hub-${uniqueSuffix}'
  aiProject: '${prefix}-proj-${uniqueSuffix}'
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    name: names.storage
    tags: tags
  }
}

module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    name: names.keyVault
    tags: tags
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    name: names.containerRegistry
    tags: tags
  }
}

module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    name: names.appInsights
    tags: tags
  }
}

module openAI 'modules/openai.bicep' = {
  name: 'openAI'
  params: {
    location: location
    name: names.openai
    tags: tags
    deployGpt55: deployGpt55
    deployGpt54: deployGpt54
    deployGpt54pro: deployGpt54pro
    deployGpt54mini: deployGpt54mini
    deployGpt54nano: deployGpt54nano
    deployGpt53codex: deployGpt53codex
    deployGpt52: deployGpt52
    deployGpt52codex: deployGpt52codex
    capacity: gptDeploymentCapacity
  }
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'aiHub'
  params: {
    location: location
    name: names.aiHub
    tags: tags
    storageAccountId: storage.outputs.id
    keyVaultId: keyVault.outputs.id
    containerRegistryId: containerRegistry.outputs.id
    applicationInsightsId: appInsights.outputs.id
    openAIId: openAI.outputs.id
  }
}

module aiProject 'modules/ai-project.bicep' = {
  name: 'aiProject'
  params: {
    location: location
    name: names.aiProject
    tags: tags
    hubId: aiHub.outputs.id
  }
}

output aiProjectName string = aiProject.outputs.name
output aiHubName string = aiHub.outputs.name
output openAIEndpoint string = openAI.outputs.endpoint
