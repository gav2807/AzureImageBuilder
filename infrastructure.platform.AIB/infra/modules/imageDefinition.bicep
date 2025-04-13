param imageDefinition imageDefinitionType
param location string
param computeGalleryName string

resource acg 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: computeGalleryName
}

resource image 'Microsoft.Compute/galleries/images@2022-03-03' = {
  name: imageDefinition.name
  location: location
  parent: acg
  properties: {
    architecture: 'x64'
    identifier: {
      offer: imageDefinition.offer
      publisher: imageDefinition.?publisher ?? 'lab'
      sku: imageDefinition.sku
    }
    osState: 'Generalized'
    osType: imageDefinition.?osType ?? 'Windows'
    hyperVGeneration: 'V2' 
  }
  tags: resourceGroup().tags
}

type imageDefinitionType = {
  name: string
  offer: string
  publisher: string?
  sku: string
  osType: osType?
}

type osType = 'Windows' | 'Linux'

output properties object = {
  name: image.name
  id: image.id
}
