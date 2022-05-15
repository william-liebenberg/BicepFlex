param thisisnotused string = 'fdefautl'


var name = 'azsydlive'

resource storageaccount  '@2021-02-01' = {
  name: 'stg${name}'
  location: 'AustraliaEast'
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
  sku: {
    name: 'Premium_LRS'
  }
}

