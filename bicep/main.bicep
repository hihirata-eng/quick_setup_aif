@description('Azure region for all resources')
@metadata({
  strongType: 'location'
})
param location string = resourceGroup().location

@description('Prefix for all resource names (3-8 lowercase alphanumeric characters)')
@minLength(3)
@maxLength(8)
param prefix string = 'aif'

@description('デプロイする GPT モデル名')
@allowed([
  'gpt-5.5'
  'gpt-5.4'
  'gpt-5.4-pro'
  'gpt-5.4-mini'
  'gpt-5.4-nano'
  'gpt-5.3-codex'
  'gpt-5.2'
  'gpt-5.2-codex'
  'gpt-5.1'
  'gpt-5'
  'gpt-5-mini'
  'gpt-5-nano'
  'gpt-4.1'
  'gpt-4.1-mini'
  'gpt-4.1-nano'
  'o4-mini'
  'o3'
  'gpt-4o'
  'gpt-4o-mini'
])
param gptModelName string = 'gpt-5.4'

@description('Tokens per minute capacity (in thousands)')
@minValue(1)
@maxValue(100)
param gptDeploymentCapacity int = 10

// モデル名からバージョンを自動解決するマッピング
var modelVersionMap = {
  'gpt-5.5': '2026-04-24'
  'gpt-5.4': '2026-03-05'
  'gpt-5.4-pro': '2026-03-05'
  'gpt-5.4-mini': '2026-03-17'
  'gpt-5.4-nano': '2026-03-17'
  'gpt-5.3-codex': '2026-02-24'
  'gpt-5.2': '2025-12-11'
  'gpt-5.2-codex': '2026-01-14'
  'gpt-5.1': '2025-11-13'
  'gpt-5': '2025-08-07'
  'gpt-5-mini': '2025-08-07'
  'gpt-5-nano': '2025-08-07'
  'gpt-4.1': '2025-04-14'
  'gpt-4.1-mini': '2025-04-14'
  'gpt-4.1-nano': '2025-04-14'
  'o4-mini': '2025-04-16'
  o3: '2025-04-16'
  'gpt-4o': '2024-11-20'
  'gpt-4o-mini': '2024-07-18'
}

var modelSkuMap = {
  'gpt-5.5': 'GlobalStandard'
  'gpt-5.4': 'GlobalStandard'
  'gpt-5.4-pro': 'GlobalStandard'
  'gpt-5.4-mini': 'GlobalStandard'
  'gpt-5.4-nano': 'GlobalStandard'
  'gpt-5.3-codex': 'GlobalStandard'
  'gpt-5.2': 'GlobalStandard'
  'gpt-5.2-codex': 'GlobalStandard'
  'gpt-5.1': 'GlobalStandard'
  'gpt-5': 'GlobalStandard'
  'gpt-5-mini': 'GlobalStandard'
  'gpt-5-nano': 'GlobalStandard'
  'gpt-4.1': 'GlobalStandard'
  'gpt-4.1-mini': 'GlobalStandard'
  'gpt-4.1-nano': 'GlobalStandard'
  'o4-mini': 'GlobalStandard'
  o3: 'GlobalStandard'
  'gpt-4o': 'GlobalStandard'
  'gpt-4o-mini': 'GlobalStandard'
}

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
    gptModelName: gptModelName
    gptModelVersion: modelVersionMap[gptModelName]
    gptModelSku: modelSkuMap[gptModelName]
    gptDeploymentCapacity: gptDeploymentCapacity
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
