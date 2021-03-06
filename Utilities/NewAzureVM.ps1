Param(
    [parameter(Mandatory = $true)] $Computername,
    [parameter(Mandatory = $true)] $ResourceLocation,
    [parameter(Mandatory = $true)] $Username,
    [parameter(Mandatory = $true)] [SecureString] $Password

)

# Create a resource group
$ResourceGroup = New-AzureRmResourceGroup -Name ResourceGroup1 -Location $ResourceLocation -Verbose

# Register required ResourceProviders
$ResourceProviders = "Microsoft.NETWORK", "Microsoft.COMPUTE", "Microsoft.Storage"
$ResourceProviders |  ForEach-Object {
    Register-AzureRmResourceProvider -ProviderNamespace $_ -verbose -ErrorAction 'SilentlyContinue' | Out-Null
}

# Get all resource groups in AzureRM
#Get-AzureRmResourceGroup -Verbose

# Get all AzureRM locations that contain name India
#Get-AzureRmLocation | ?{$_.location -like "*India*"} 


# SETUP NETWORK    
# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name Subnet -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -Name MYvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig -WarningAction SilentlyContinue -Verbose

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)" -WarningAction SilentlyContinue -Verbose

# Create an inbound network security group rule for port 3389 (RDP)
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name NetworkSecurityGroupRuleRDP  -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 3389 -Access Allow

# Create an inbound network security group rule for port 80 (HTTP)
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleWWW  -Protocol Tcp `
    -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80 -Access Allow

# Create an inbound network security group rule for port 5986 (WS-Management)
$nsgRuleWinRM = New-AzureRmNetworkSecurityRuleConfig -Name NetworkSecurityGroupRuleWinRM  -Protocol Tcp `
    -Direction Inbound -Priority 1002 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 5986 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -Name myNetworkSecurityGroup -SecurityRules $nsgRuleRDP,$nsgRuleWeb,$nsgRuleWinRM -Verbose -WarningAction SilentlyContinue

# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -Name NIC -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceLocation `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -Verbose -WarningAction SilentlyContinue


# Define a credential object
$Credentials = New-Object pscredential ($Username, $Password)

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName WinServer2016 -VMSize Standard_DS2 | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName $ComputerName -Credential $Credentials | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest -Verbose | Add-AzureRmVMNetworkInterface -Id $nic.Id -Verbose


New-AzureRmVM -ResourceGroupName $ResourceGroup.ResourceGroupName `
              -Location $ResourceLocation -VM $vmConfig -Verbose

