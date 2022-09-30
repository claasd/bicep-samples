param name string = 'demo-${uniqueString(resourceGroup().id)}'
param storageName string = 'stdemo${uniqueString(resourceGroup().id)}'
param clientId string
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-04-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
  properties: {
    httpsOnly: true
    
    siteConfig: {
      // this allows data only from Azure.
      // you could also use a specific region, like AzureCloud.westeurope 
      ipSecurityRestrictions: [
        {
          action: 'Allow'
          name: 'Only Azure Datacenter' // only 32 characters allowed
          priority: 100
          tag: 'ServiceTag'
          ipAddress: 'AzureCloud'
        }
      ]
      http20Enabled: true
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listkeys(storageAccount.id, '2019-06-01').keys[0].value};'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'netFrameworkVersion'
          value: 'v6.0'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listkeys(storageAccount.id, '2019-06-01').keys[0].value};'
        }
      ]
    }
  }
}

resource funcAuthSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'authsettingsV2'
  parent: functionApp
  properties: {
    platform: {
      enabled: true
    }
    httpSettings: {
      requireHttps: true
    }
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        isAutoProvisioned: false
        registration: {
          clientId: clientId
          openIdIssuer: 'https://sts.windows.net/${subscription().tenantId}/'
        }
        // uncomment the following lines if you want to grant access to others than APIM
        validation: {
          allowedAudiences: [
            apim.identity.principalId
          ]
        }
      }
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2019-01-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: {}
  sku: {
    name: 'Consumption'
  }
  properties: {
    publisherEmail: 'demo@invalid-domain.netcom'
    publisherName: 'N/A'
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'demoApi'
  parent: apim
  properties: {
    displayName: 'demoAPI'
    serviceUrl: 'https://${functionApp.name}.azurewebsites.net/api'
    path: 'demo'
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    isCurrent: true
    format: 'openapi'
    value: loadTextContent('demo-api.yml')
  }
}

var policyContent = loadTextContent('apim-policy.xml')

resource policy 'Microsoft.ApiManagement/service/apis/policies@2021-08-01' = {
  name: 'policy'
  parent: api
  properties: {
    value: replace(policyContent, '#clientId#', clientId)
    format: 'xml'
  }
}
