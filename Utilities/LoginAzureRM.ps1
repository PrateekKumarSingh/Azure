param(
    [String] $SubscriptionID,
    [String] $Username,
    [SecureString] $Password
)

# Install, import AzureRM module and Login to Azure account
$Module = Get-Module AzureRM
If(-not $Module)
{
    Write-Host "Import/Install AzureRM Module." -ForegroundColor Yellow
    Import-Module AzureRM -ErrorAction SilentlyContinue
    If(-not $?)
    {
        Write-Host "Unable to find 'AzureRM' module on local machine`nImporting 'AzureRM' from Powershell Gallery." -ForegroundColor Yellow
        Install-Module AzureRM -Scope CurrentUser -Force -AllowClobber
    }
}
else {
    Write-Host "AzureRM v$($Module.Version) found. Proceeding." -ForegroundColor Green
}

Write-Host "Attempting login on Azure portal" -Foreground Yellow

$Login = Login-AzureRmAccount -SubscriptionId $SubscriptionID 
                              -Credential New-Object System.Management.Automation.PSCredential ($Username, $Password)

if($Login){
    Write-Host "Login successful. Following are account\subscription details -" -ForegroundColor Yellow
    $Login
}
else{
    Write-Host "Unsuccessful login attempt. Please retry." -ForegroundColor Red
}
