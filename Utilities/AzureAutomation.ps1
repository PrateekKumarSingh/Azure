# 1. Create an Azure automation account if not already
$Account = New-AzureRmAutomationAccount -ResourceGroupName ResourceGroup1 `
                                        -Name AzureAutomationAcc1 `
                                        -Location SouthEastAsia `
                                        -Verbose 



# Incase you already have an account                                        
# $Account = Get-AzureRmAutomationAccount    

# Create a new automation runbook and edit it in Azure portal
$NameOfRunbook =  "PowershellRunbook1"
New-AzureRmAutomationRunbook -AutomationAccountName $Account.AutomationAccountName `
                             -Name $NameOfRunbook `
                             -Type PowerShell `
                             -ResourceGroupName $Account.ResourceGroupName `
                             -Verbose                             

# [Alternatively] Import a powershell script and create a Runbook with that
Import-AzureRmAutomationRunbook -Name PowerShellRunbook1 `
                                -Path .\Runbooks\NewVM.ps1 `
                                -ResourceGroupName $Account.ResourceGroupName `
                                -AutomationAccountName $Account.AutomationAccountName `
                                -Type PowerShell -Verbose -Published -LogVerbose $true

Import-AzureRmAutomationRunbook -Name CleanSlate `
                                -Path .\Runbooks\RemoveAllExceptAutomation.ps1 `
                                -ResourceGroupName $Account.ResourceGroupName `
                                -AutomationAccountName $Account.AutomationAccountName `
                                -Type PowerShell -Verbose -Published -LogVerbose $true
                          
# Get a specific azure automation runbook
Get-AzureRmAutomationRunbook -ResourceGroupName resourcegroup1 `
-AutomationAccountName azureautomationacc1 `
-Name 'PowershellRunbook1'

# Remove a specific azure automation runbook
Get-AzureRmAutomationRunbook -ResourceGroupName resourcegroup1 `
-AutomationAccountName azureautomationacc1 `
-Name 'CleanSlate' | Remove-AzureRmAutomationRunbook -Verbose -Force


# Start a specific azure automation runbook
Get-AzureRmAutomationRunbook -ResourceGroupName resourcegroup1 `
-AutomationAccountName azureautomationacc1 `
    -Name 'PowershellRunbook1' |Start-AzureRmAutomationRunbook -Verbose -Wait | Get-AzureAutomationJobOutput -Stream Any

# Start a specific azure automation runbook
Get-AzureRmAutomationRunbook -ResourceGroupName resourcegroup1 `
-AutomationAccountName azureautomationacc1 `
-Name 'cleanslate' |Start-AzureRmAutomationRunbook -Verbose -Wait

$ConnectionAssetName = "AzureRunAsConnection"
$ConnectionFieldValues = @{"ApplicationId" = $Application.ApplicationId; "TenantId" = $TenantID.TenantId; "CertificateThumbprint" = $Cert.Thumbprint; "SubscriptionId" = $SubscriptionId}
New-AzureRmAutomationConnection -ResourceGroupName ResourceGroup1 `
-AutomationAccountName AzureAutomationAcc1 -Name $ConnectionAssetName -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues $ConnectionFieldValues


$Password = ConvertTo-SecureString -String "Durg@v@ti@123" -AsPlainText -Force
New-AzureRmAutomationCertificate -AutomationAccountName "AzureAutomationacc1" -Name "AzureCertificate" -Path "./AzureCertificate.pfx" -Password $Password -ResourceGroupName "ResourceGroup1"