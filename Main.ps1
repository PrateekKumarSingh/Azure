
. $PSScriptRoot\Utilities\ConvertTo-Hashtable.ps1
$data = ConvertTo-Hashtable -Path KeysAndIDs.csv

. $PSScriptRoot\Utilities\LoginAzureRM.ps1 -SubscriptionID $data['SubscriptionID']
                                           -Username $data['Username']
                                           -Password $(ConvertTo-SecureString -String $data['Password'] -AsPlainText -Force)
                                           
. $PSScriptRoot\Utilities\NewAzureVM.ps1 -ComputerName 'WindowsServer2016' -ResourceLocation 'southeastasia'


