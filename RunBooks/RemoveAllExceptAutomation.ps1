# to authenticate your runbook woi
$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
    -ApplicationID $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
    
    $VM = Get-AzureRmVM -ResourceGroupName "ResourceGroup1"
    $VM = $VM | Remove-AzureRmVMDataDisk -DataDiskNames $VM.StorageProfile.OsDisk.Name -Verbose 
    $VM | Update-AzureRmVM -Verbose
    
Get-AzureRmResource |Where-Object name -NotLike "*automation*"| Remove-AzureRmResource -Verbose -Force -ErrorAction SilentlyContinue

