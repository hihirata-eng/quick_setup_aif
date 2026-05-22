param location string
param name string
param tags object = {}
param hubId string

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    hubResourceId: hubId
  }
}

output id string = aiProject.id
output name string = aiProject.name
