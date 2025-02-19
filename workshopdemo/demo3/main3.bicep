module storage 'br/public:avm/res/storage/storage-account:0.17.4' = {
  name: 'myStorageAccount'
  params: {
    name: 'sa${resourceGroup().name}'
  }
}
