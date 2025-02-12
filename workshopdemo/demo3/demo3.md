# デモ 3

## このデモのゴール

* Azure Container Registry を構築
* モジュールを Azure Container Registry にプッシュ
* Azure Container Registry にあるリモート モジュールを使用してリソースをデプロイ
* AVM にあるリモート モジュールを使用してリソースをデプロイ

## デモ3-1: ローカル モジュールの作成

ファイルの配置は以下のようになっています。

```bash
│  main.bicep
│  
└─modules
        cdn.bicep
        website.bicep
```

この場合、```main.bicep``` から ```website.bicep``` と ```cdn.bicep``` を呼び出せます。

```bicep
module website './modules/website.bicep' = {
  name: 'otameshi-website'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn './modules/cdn.bicep' = {
  name: 'otameshi-cdn'
  params: {
    httpsOnly: true
    originHostName: website.outputs.appServiceAppHostName
  }
}
```

```bash
$ az group create --name <RESOURCE_GROUP_NAME> --location japaneast
$ az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file .\modules\website.bicep
```

デプロイ結果を確認し、リソースが作成されていることを確認します。
確認ができましたら、リソース グループを削除します (オプション)。

```bash
$ az group delete --name <RESOURCE_GROUP_NAME> --no-wait
```

## デモ3-2: リモート モジュールの利用

次に、リモートにて管理されているモジュールを利用します。
リモート モジュールの利用としては、公開されているモジュール (AVM: Azure Verified Modules) リポジトリ、
もしくは、Azure Container Registry (ACR) にプッシュされたモジュールを利用することができます。

```bicep

Aure Container Registry (ACR) を作成し、モジュールファイル (```website.bicep``` と ```cdn.bicep```) をプッシュします。
まずは、ACR をデプロイします。

```bash
$ az group create --name <RESOURCE_GROUP_NAME> --location japaneast
$ az acr create --resource-group <RESOURCE_GROUP_NAME> --name <ACR 名はグローバルで一意になる必要があります> --sku Basic --location japaneast
$ az acr repository list --name <registry-name>
[]
```

次に、モジュールファイルを ACR にプッシュします。

```bash
$ az bicep publish --file .\modules\website.bicep --target 'br:<registry-name>.azurecr.io/website:v1'
$ az bicep publish --file .\modules\cdn.bicep --target 'br:<registry-name>.azurecr.io/cdn:v1'
$ az acr repository list --name <registry-name>           
[
  "cdn",
  "website"
]
$ az acr repository show-tags -n <registry-name> --repository cdn --output tsv
v1
$ az acr repository show-tags -n <registry-name> --repository website --output tsv
v1
```

それでは、リモート モジュールを利用してリソースをデプロイします。
なお、リモートモジュールを参照する Bicep ファイルでは、以下のような書式となります。
Bicep ファイルで記載すると、Bicep 拡張機能により、ローカルへのコピー ([bicep restore](https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/bicep-cli#restore)) が行われます。

```bicep
module website 'br:<registry-name>.azurecr.io/website:v1' = {
  name: 'otameshi-website'
  params: {
    appServiceAppName: appServiceAppName
    appServicePlanName: appServicePlanName
    appServicePlanSkuName: appServicePlanSkuName
    location: location
  }
}

module cdn 'br:<registry-name>.azurecr.io/cdn:v1' = {
  name: 'otameshi-cdn'
  params: {
    httpsOnly: true
    originHostName: website.outputs.appServiceAppHostName
  }
}
```

```bash
$ az deployment group create --resource-group <RESOURCE_GROUP_NAME> --template-file .\main2.bicep
```

デプロイ結果を確認し、リソースが作成されていることを確認します。
確認ができましたら、リソース グループを削除します (オプション)。

```bash
$ az group delete --name <RESOURCE_GROUP_NAME> --no-wait
```

以上でデモ1は終了です。