param(
    [String] $SubscriptionID,
    [String] $Username,
    [SecureString] $Password
)

# Install, import AzureRM module and Login to Azure account
$Module = Get-Module AzureRM
If(-not $Module){
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

$Login = Import-AzureRmContext -Profile .\profile.json -Verbose
#Select-AzureRmContext "default" -Verbose

if($Login){
    Write-Host "Login successful." -ForegroundColor Yellow
    $Subscription = Get-AzureRmSubscription | Where-Object state -eq enabled
    Select-AzureRmSubscription -SubscriptionId $Subscription.Id -Verbose 
}
else{
    Write-Host "Unsuccessful login attempt. Please retry." -ForegroundColor Red
}
