@description('Name of the environment. Used in resource names.')
@allowed([
  'staging'
  'production'
])
param environmentName string
@description('Azure region for all resources.')
param location string = resourceGroup().location
@description('App Service plan SKU.')
param skuName string = 'B1'
@description('App Configuration SKU. Only one free store is allowed per subscription.')
@allowed([
  'free'
  'standard'
])
param appConfigSku string = 'free'
var suffix = uniqueString(resourceGroup().id)
var planName = 'plan-lab2-${environmentName}'
var webAppName = 'app-lab2-${environmentName}-${suffix}'
var appConfigName = 'appcs-lab2-${environmentName}-${suffix}'
// Built-in role: App Configuration Data Reader
var appConfigDataReaderRoleId = '516239f1-63e1-4d78-a4de-a74fb236a071'
resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: planName
  location: location
  kind: 'linux'
  sku: {
    name: skuName
  }
  properties: {
    reserved: true
  }
}
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  sku: {
    name: appConfigSku
  }
}
resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      alwaysOn: true
      healthCheckPath: '/health'
      appSettings: [
        {
          name: 'APP_ENVIRONMENT'
          value: environmentName
        }
        {
          name: 'APPCONFIG_ENDPOINT'
          value: appConfig.properties.endpoint
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
    }
  }
}
resource appConfigReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfig.id, webApp.id, appConfigDataReaderRoleId)
  scope: appConfig
  properties: {
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', appConfigDataReaderRoleId)
  }
}
output webAppName string = webApp.name
output webAppHostName string = webApp.properties.defaultHostName
output appConfigName string = appConfig.name
output appConfigEndpoint string = appConfig.properties.endpoint
