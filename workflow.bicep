extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

param repo string

var builtInRoleNames = {
  'Application.ReadWrite.OwnedBy': '18a4783c-866b-4cc7-a460-3d5e5662c884'
}

module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  params: {
    name: 'workflow'
    federatedIdentityCredentials: [
      {
        name: 'workflow-fid'
        issuer: 'https://token.actions.githubusercontent.com'
        subject: 'repo:${repo}:ref:refs/heads/main'
        audiences: [
          'api://AzureADTokenExchange'
        ]
      }
    ]
  }
}

module roleAssignment 'br/public:avm/res/authorization/role-assignment/rg-scope:0.1.0' = {
  params: {
    principalId: identity.outputs.principalId
    roleDefinitionIdOrName: 'Owner'
    // Avoids replication delay issue by skipping checking whether the principal exists
    principalType: 'ServicePrincipal'
  }
}

resource graphPrincipal 'Microsoft.Graph/servicePrincipals@v1.0' existing = {
  // Well-known ID of Microsoft Graph app
  appId: '00000003-0000-0000-c000-000000000000'
}

// Sometimes fails due to replication delay with error message "Not a valid reference update."
// https://github.com/microsoftgraph/msgraph-bicep-types/issues/193
// Try deploying again
resource appRoleAssignment 'Microsoft.Graph/appRoleAssignedTo@v1.0' = {
  appRoleId: builtInRoleNames['Application.ReadWrite.OwnedBy']
  principalId: identity.outputs.principalId
  resourceId: graphPrincipal.id
}


type githubSecret = {
  name: string
  secret: string
}

output secrets githubSecret[] = [
  {
    name: 'AZURE_TENANT_ID'
    secret: tenant().tenantId
  }
  {
    name: 'AZURE_SUBSCRIPTION_ID'
    secret: subscription().subscriptionId
  }
  {
    name: 'AZURE_RESOURCE_GROUP_NAME'
    secret: resourceGroup().name
  }
  {
    name: 'AZURE_CLIENT_ID'
    secret: identity.outputs.clientId
  }
]
