#requires -Module Microsoft.PowerShell.SecretManagement
#requires -Module Microsoft.PowerShell.SecretStore
    
function Get-OrCreateSecret {
    <#
    .SYNOPSIS
        Gets secret from local vault or creates it if it does not exist.
    .DESCRIPTION
        This function retrieves a secret from the local vault or creates it if it does not exist.
    .Parameter SecretName
        Name of the secret to retrieve or create.
        Recommended to use the username or public key / client id.
    .EXAMPLE
        $password = Get-OrCreateSecret -SecretName $username
    .EXAMPLE
        $clientSecret = Get-OrCreateSecret -SecretName $clientId
    .LINK
        https://github.com/scottmckendry/Windots/blob/main/Profile.ps1
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('name')]
        [string]$SecretName
    )

    $secretFolder = "$(Split-Path $env:DOTFILES)\secrets"
    if (Test-Path "$secretFolder\secrets.xml") {
        $secretSecurePath = "$secretFolder\secrets.xml"
    }
    else {
        $secretSecurePath = Read-Host "Enter the path you stored decrypted password file"
    }

    if (Test-Path $secretSecurePath) {
        $myPassword = Import-Clixml -Path $secretSecurePath
        Unlock-SecretStore -Password $myPassword
    }

    ''
    Write-Host "Retrieve secret" -ForegroundColor "Blue" -NoNewline
    Write-Host " $SecretName " -ForegroundColor "White" -NoNewline
    Write-Host "from local vault..." -ForegroundColor "Blue"
    $SecretValue = Get-Secret $SecretName -AsPlainText -ErrorAction SilentlyContinue

    if (!$SecretValue) {
        $createSecret = Read-Host "No secret found matching $SecretName, create one? (Y/n)"

        if ($createSecret.ToUpper() -eq "Y") {
            $SecretValue = Read-Host -Prompt "Enter secret value for ($SecretName)" -AsSecureString
            Set-Secret -Name $SecretName -SecureStringSecret $SecretValue
            $SecretValue = Get-Secret $SecretName -AsPlainText
        }
        else {
            throw "Secret not found and not created. Exiting."
        }
    }
    ''
    return $SecretValue
}