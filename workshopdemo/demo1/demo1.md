# デモ 1

## このデモの目的

Azure Bicep の最も基本的な "リソース" について紹介します。

## デモの手順

### デモ1-1. Bicep ファイルを用いてストレージ アカウントを作成

Azure Bicep ファイルを作成します。

```bicep
param location string = resourceGroup().location
param storageAccountName string = 'sa${uniqueString(resourceGroup().id)}'
param storageAccountType string = 'Premium_LRS'

resource str 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
```

```bash
$ az group create --name <RESOURCE_GROUP_NAME> --location japaneast
$ az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file main.bicep
```

Azure ポータルより対象リソースが作成されたことを確認し、リソース グループを削除します (オプション)。

```bash
$ az group delete --name <RESOURCE_GROUP_NAME> --no-wait --yes
```

### デモ1-2. パラメータファイルを指定して再度ストレージ アカウントをデプロイ

次にパラメータファイル (```storageparam.bicepparam```) を以下の内容で作成します。

```bicep
using './main.bicep'

param storageAccountType = 'Standard_LRS'
param storageAccountName = 'otameshisa7b1b'
```

このパラメータファイルを利用して、Bicep ファイルをデプロイします。

```bash
$ az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file main.bicep --parameters storageparam.bicepparam
```

Azure ポータルより対象リソースが作成されたことを確認し、リソース グループを削除します (オプション)。

```bash
$ az group delete --name <RESOURCE_GROUP_NAME> --no-wait --yes
```

### デモ1-3. キーコンテナーよりシークレットの取得

キーコンテナを作成し、適当なパスワードをシークレットとして登録します。

```bash
$ az group create --name <RESOURCE_GROUP_NAME> --location japaneast
$ az keyvault create --name <your-unique-keyvault-name> --resource-group <RESOURCE_GROUP_NAME> --location japaneast --enabled-for-template-deployment true

なお、シークレットの作成操作には、予め Key Vault Secrets Officer のロールが割り当てられている必要があります。

```bash
$ az role assignment create --role "Key Vault Secrets Officer" --assignee "<upn>" --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.KeyVault/vaults/<your-unique-keyvault-name>"
$ az keyvault secret set --vault-name <your-unique-keyvault-name> --name "testpd" --value "myPassword12"
```

それではこのシークレットを使う Bicep ファイルの方を見てみます。
まず、既に作成されているキーコンテナを参照するため、```existing``` リソースを利用します。
次に、シークレットを取得するため、```kv.getSecret()``` 関数を利用します。
なお、この関数は、```@secure()``` デコレーターを持つモジュール パラメーターで、かつモジュールの ```params``` セクション内からしか使用できません。

```bicep
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
  scope: resourceGroup(subscriptionId, kvResourceGroupName)
}

module sql './modules/sql.bicep' = {
  name: 'sql'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminLogin: adminLogin
    adminLoginPassword: kv.getSecret('testpd')
  }
}
```

こちらも確認が取れましたら、リソース グループを削除します (オプション)。

```bash
$ az group delete --name <RESOURCE_GROUP_NAME> --no-wait --yes
```

以上でデモ1は終了です。