param location string
param name string
param tags object = {}

param deployGpt55 bool = false
param deployGpt54 bool = true
param deployGpt54pro bool = false
param deployGpt54mini bool = false
param deployGpt54nano bool = false
param deployGpt53codex bool = false
param deployGpt52 bool = false
param deployGpt52codex bool = false

@minValue(1)
@maxValue(100)
param capacity int = 10

resource openAI 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

resource dep55 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt55) {
  parent: openAI
  name: 'gpt-5.5'
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.5', version: '2026-04-24' }
  }
}

resource dep54 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt54) {
  parent: openAI
  name: 'gpt-5.4'
  dependsOn: [dep55]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.4', version: '2026-03-05' }
  }
}

resource dep54pro 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt54pro) {
  parent: openAI
  name: 'gpt-5.4-pro'
  dependsOn: [dep54]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.4-pro', version: '2026-03-05' }
  }
}

resource dep54mini 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt54mini) {
  parent: openAI
  name: 'gpt-5.4-mini'
  dependsOn: [dep54pro]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.4-mini', version: '2026-03-17' }
  }
}

resource dep54nano 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt54nano) {
  parent: openAI
  name: 'gpt-5.4-nano'
  dependsOn: [dep54mini]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.4-nano', version: '2026-03-17' }
  }
}

resource dep53codex 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt53codex) {
  parent: openAI
  name: 'gpt-5.3-codex'
  dependsOn: [dep54nano]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.3-codex', version: '2026-02-24' }
  }
}

resource dep52 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt52) {
  parent: openAI
  name: 'gpt-5.2'
  dependsOn: [dep53codex]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.2', version: '2025-12-11' }
  }
}

resource dep52codex 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = if (deployGpt52codex) {
  parent: openAI
  name: 'gpt-5.2-codex'
  dependsOn: [dep52]
  sku: { name: 'GlobalStandard', capacity: capacity }
  properties: {
    model: { format: 'OpenAI', name: 'gpt-5.2-codex', version: '2026-01-14' }
  }
}

output id string = openAI.id
output endpoint string = openAI.properties.endpoint

