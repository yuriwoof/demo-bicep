# テンプレート化

ここでは、組織の中で各プロジェクトサブスクリプション、リソース グループ等を払い出す業務を想定したテンプレートを扱います。

## サブスクリプションの作成

```bash
# サブスクリプションの作成
$ az deployment mg create --name demo7 --location japaneast --template-file .\workshopdemo\demo7\subscription\subscription.bicep
```

* [最新の API を使用してプログラムで Azure Enterprise Agreement サブスクリプションを作成する](https://learn.microsoft.com/ja-jp/azure/cost-management-billing/manage/programmatically-create-subscription-enterprise-agreement?tabs=azure-cli#use-arm-template-or-bicep)

## リソース グループの作成

```bash
# リソース グループの作成
$ az deployment sub create --name createrg --location japaneast --template-file .\workshopdemo\demo7\resourcegroup\rg.bicep
Please provide string value for 'resourceGroupName' (? for help): rg-test

# 出力の取得
$ az deployment sub show -n createrg --query properties.outputs.resourceGroupName.value
"rg-test"
```

## リソース グループに権限付与

```bash
# リソース グループに権限付与
$ az deployment group create --resource-group rg-test --template-file .\workshopdemo\demo7\roleassignment\roleassignment.bicep
Please provide string value for 'principalId' (? for help): <User Object ID>

# 出力の取得
$ az deployment group show --resource-group rg-test -n roleassignment --query properties.outputs.name.value    
"44d3598f-07cf-5db2-aae7-6adc2ad16221"
```

* ロール定義情報の取得

```bash
$ az role definition list --name Contributor 
```

* ユーザーのオブジェクト ID の取得

```bash
$ az ad user list --query "[?displayName=='<User Display Name>'].id" -o tsv
```

## 仮想ネットワークの作成

```bash
# 仮想ネットワークの作成
$ az deployment group create --resource-group rg-test --template-file .\workshopdemo\demo7\vnet\vnet.bicep
Please provide string value for 'vnetName' (? for help): vnet-test

# 出力の取得
$ az deployment group show --resource-group rg-test -n vnet --query properties.outputs.vnetName.value
"vnet-test"
```

## サブネットの作成

```bash
# サブネットの作成
$ az deployment group create --resource-group rg-test --template-file .\workshopdemo\demo7\subnet\subnet.bicep
Please provide string value for 'virtualNetworkName' (? for help): vnet-test
Please provide string value for 'subnetName' (? for help): second

# 出力の取得
az deployment group show --resource-group rg-test -n subnet --query properties.outputs.subnetName.value
"second"
```

## ネットワーク セキュリティ グループの作成

```bash
# ネットワーク セキュリティ グループの作成
$ az deployment group create --resource-group rg-test --template-file .\workshopdemo\demo7\nsg\nsg.bicep 
Please provide string value for 'nsgName' (? for help): nsg-test
Please provide string value for 'vnetName' (? for help): vnet-test
Please provide string value for 'subnetName' (? for help): second

# 出力の取得
$  az deployment group show --resource-group rg-test -n nsg --query properties.outputs.nsgName.value
"nsg-test"
```

## ルートテーブルの作成

```bash
$ az deployment group create --resource-group rg-test --template-file .\workshopdemo\demo7\udr\udr.bicep
Please provide string value for 'routeTableName' (? for help): udr-test
Please provide string value for 'vnetName' (? for help): vnet-test
Please provide string value for 'subnetName' (? for help): second
Please provide string value for 'virtualApplianceIpAddress' (? for help): 192.168.0.5

# 出力の取得
az deployment group show --resource-group rg-test -n udr --query properties.outputs.routeTableName.value
"udr-test"
```