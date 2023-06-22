@description('Environment prefix')
@allowed([
  'DEV'
  'STG'
  'PRD'
])
param envPrefix string

@description('Web App Name')
@minLength(2)
param webAppName string

@description('Describes plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param sku string = 'F1'

@description('The runtime stack of web app with the format: Programming language stack | Version')
param linuxFxVersion string = 'DOTNETCORE|6.0'

@description('App Region')
param location string = resourceGroup().location // Location for all resources

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${envPrefix}-AppServicePlan-${webAppName}'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${envPrefix}-${webAppName}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}
