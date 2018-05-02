# Removing all AzureRM resource groups
Get-AzureRmResourceGroup | Remove-AzureRmResourceGroup -Verbose
Get-AzureRmResource |Where-Object name -NotLike "*automation*" | Remove-AzureRmResource -Verbose -Force

