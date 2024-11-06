function New-SecretVault {
    <#
    .SYNOPSIS
        Setup a SecretVault on a local machine.
    .DESCRIPTION
        This function will configure a SecretManagement modules and setup SecretVault using SecretStore module on local machine.
    .LINK
        https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/using-secrets-in-automation?view=ps-modules
    #>
    #requires -Module Microsoft.PowerShell.SecretManagement
    #requires -Module Microsoft.PowerShell.SecretStore

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [Alias('name')]
        [string]$VaultName,

        [Parameter(Mandatory = $True, Position = 1)]
        [Alias('path')]
        [string]$StoredPath
    )

    $UserName = Read-Host "Input your UserName here"
    $credential = Get-Credential -UserName $UserName
    $credential.Password | Export-Clixml -Path $StoredPath

    Register-SecretVault -Name $VaultName -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
    $myPassword = Import-Clixml -Path $StoredPath

    $storeConfiguration = @{
        Authentication  = "Password"
        PasswordTimeout = 3600 # 1 hour
        Interaction     = "None"
        Password        = $myPassword
        Confirm         = $False 
    }
    Set-SecretStoreConfiguration @storeConfiguration
    Write-Host "Secret Vault $VaultName created and configured successfully."
}