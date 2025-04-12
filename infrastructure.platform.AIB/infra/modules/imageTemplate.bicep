param imageTemplateName string
param customizers array
param environment string
param location string = resourceGroup().location
param vmSize string = 'Standard_D5_v2'
param diskSize int = 127
param computeGalleryName string
param imageDefinitionName string
param image imageType
param osName string
param version string
param resourceGroupName string = 'az-uks-${environment}-${osName}-aib-imgtmp-rg'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'az-uks-${environment}-aib-id'
  scope: resourceGroup('az-uks-${environment}-gallery-rg')
}

resource acg 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: computeGalleryName
  scope: resourceGroup('az-uks-${environment}-gallery-rg')
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: 'az-uks-${environment}-aib-lan-vnet'
  scope: resourceGroup('az-uks-${environment}-network-rg')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  name: 'imagebuilder-sn'
  parent: vnet
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName 
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 120
    source: {
      type: 'PlatformImage'
      publisher: image.publisher
      offer: image.offer
      sku: image.sku
      version: image.version
      planInfo: empty(image.planInfo) ? null : image.planInfo
    }
    stagingResourceGroup: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupName}'
    validate: {}
    vmProfile: {
      osDiskSizeGB: diskSize
      vmSize: vmSize
      vnetConfig: {
        subnetId: subnet.id
      }
    }
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${acg.id}/images/${imageDefinitionName}/versions/${version}'
        runOutputName: 'acgOutput'
        replicationRegions: [
          location
        ]
      }
    ]
    customize: customizers
  }
  tags: resourceGroup().tags
}

type imageType = {
  publisher: string
  offer: string
  sku: string
  version: string
  planInfo: planInfoType?
}

type planInfoType = {
  planName: string
  planProduct: string
  planPublisher: string
}
