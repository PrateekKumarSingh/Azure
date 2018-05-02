
. $PSScriptRoot\Utilities\ConvertTo-Hashtable.ps1
$data = ConvertTo-Hashtable -Path "$PSScriptRoot\Configurations.csv"

. $PSScriptRoot\Utilities\1_LoginAzureRM.ps1 -SubscriptionID $data['SubscriptionID']
#. $PSScriptRoot\Utilities\NewAzureVM.ps1 -ComputerName $data['ComputerName'] -ResourceLocation $data['ResourceLocation'] -Username $data['AdminUsername'] -Password $(ConvertTo-SecureString -String $data['AdminPassword'] -AsPlainText -Force)


