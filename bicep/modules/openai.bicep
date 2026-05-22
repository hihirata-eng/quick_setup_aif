param location string
param name string
param tags object = {}

@description('GPT model name to deploy')
param gptModelName string

@description('GPT model version (auto-resolved from main.bicep)')
param gptModelVersion string

@description('Deployment SKU name')
param gptModelSku string = 'GlobalStandard'

@description('Tokens per minute capacity (in thousands)')
param gptDeploymentCapacity int

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

resource gptDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: openAI
  name: gptModelName
  sku: {
    name: gptModelSku
    capacity: gptDeploymentCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: gptModelName
      version: gptModelVersion
    }
  }
}

output id string = openAI.id
output endpoint string = openAI.properties.endpoint
