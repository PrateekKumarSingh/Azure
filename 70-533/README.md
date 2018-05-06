# Creating a Azure Web app

## 1. Create a App Service Plan

```PowerShell
New-AzureRmAppServicePlan -Name RidiCurious-ASP -Location centralindia -ResourceGroupName ResourceGroup1 -Tier Free
```
## 2. Create a Azure web app using the App service plan

```PowerShell
New-AzureRmWebApp -Name RidiCurious -AppServicePlan RidiCurious-ASP -ResourceGroupName ResourceGroup1 -Location centralindia 

Get-AzureRmWebApp -ResourceGroupName ResourceGroup1 -Name RidiCurious
```

## 3. Scaling up and down the app service plans
```PowerShell
# scaling up
set-AzureRmAppServicePlan -Name RidiCurious-asp -Tier -ResourceGroupName resourcegroup1

# scaling down
set-AzureRmAppServicePlan -Name RidiCurious-asp -Tier Basic -ResourceGroupName resourcegroup1
```
