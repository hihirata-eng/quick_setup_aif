param location string
param name string
param tags object = {}

@description('Object ID of the Microsoft Entra ID user to grant Key Vault Administrator role')
param userObjectId string = ''

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

output id string = keyVault.id

resource keyVaultAdministratorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (userObjectId != '') {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: resourceGroup()
}
resource keyVaultAdministratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (userObjectId != '') {
  name: guid(keyVault.id, userObjectId, keyVaultAdministratorRole.id)
  scope: keyVault
  properties: {
    principalId: userObjectId
    roleDefinitionId: keyVaultAdministratorRole.id
    principalType: 'User'
  }
}
