#Find-Module Azure -Verbose | Install-Module -Scope CurrentUser -Verbose -Force

# Instal, import AzureRM module and Login to Azure account
Install-Module AzureRM -Verbose
Import-Module AzureRM -Verbose
$Login = Login-AzureRmAccount   

# Create a resource group
$ResourceLocation = 'westus'
$ResourceGroup = New-AzureRmResourceGroup -Name FirstResourceGroup -Location $ResourceLocation -Verbose
    #Get-AzureRmResourceGroup -Verbose
    #Get-AzureRmLocation | ?{$_.location -like "*India*"} 
    #Get-AzureRmResourceGroup | Remove-AzureRmResourceGroup -Verbose

# SETUP NETWORK    
# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24
# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -Name MYvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig
# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)"


# Create an inbound network security group rule for port 3389
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleRDP  -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleWWW  -Protocol Tcp `
    -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -Name myNetworkSecurityGroup -SecurityRules $nsgRuleRDP,$nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name myNic -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id


    # Define a credential object
$cred = Get-Credential

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName WinServer2016 -VMSize Standard_DS2 | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName myVM -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

New-AzureRmVM -ResourceGroupName $ResourceGroup.ResourceGroupName `
              -Location $ResourceLocation -VM $vmConfig -Verbose
