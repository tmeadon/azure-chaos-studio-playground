param principalId string

var vmContributorRoleId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'

resource vmContributorRole 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: vmContributorRoleId
}

resource vmContributorAssignments 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().name, vmContributorRoleId, principalId)
  properties: {
    principalId: principalId
    roleDefinitionId: vmContributorRole.id
  }
  scope: resourceGroup()
}
