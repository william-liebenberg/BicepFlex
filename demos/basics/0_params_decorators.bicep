@allowed([
  'australiaeast'
  'australiasoutheast'
  'westus'
])
param location string = 'australiaeast'

// Wow we can even have normal comments :)

@description('Name of your project')
@maxLength(32)
param projectName string = 'NDCSydney2021'

@description('AppService horizontal scale intances')
@minValue(1)
@maxValue(10)
param serverInstances int = 3
