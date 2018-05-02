# 1. [On Azure VM] Enable PSRemoting, open Firewall ports and download local cert

    # Enable Powershell remotting on the Azure VM
    Enable-PSRemoting -Verbose

    # Create a self signed certificate on the Azure VM
    $Cert = New-SelfSignedCertificate -CertStoreLocation Cert:\LocalMachine\My -DnsName PrateekSingh.net
    Export-Certificate -Cert $Cert -FilePath C:\Users\Prateek\Desktop\Cert.cer 

    # Create a firewall rule inside the Azure VM
    New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
    New-NetFirewallRule -DisplayName 'WinRM HTTPS-In' -Name 'WinRM HTTPS-In' -Profile Any -LocalPort 5986 -Protocol TCP

# 2. [On Local Machine] 
    # Import the certificate generated from Server
    Get-ChildItem C:\Data\Powershell\Certs\cert.cer | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root -Verbose  

    # Enter PS session remotely on the Server
    $Creds = Get-Credential -Message 'Enter admin creds'
    $PSSessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
    
    Enter-PSSession -ConnectionUri https://52.230.9.146:5986 -Credential $creds -Authentication Negotiate -SessionOption $PSSessionOption
