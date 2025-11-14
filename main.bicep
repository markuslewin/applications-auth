extension 'br:mcr.microsoft.com/bicep/extensions/microsoftgraph/v1.0:1.0.0'

resource web 'Microsoft.Graph/applications@v1.0' = {
  displayName: 'App from workflow'
  uniqueName: 'app-from-workflow'
}
