function Get-OrCreateSecret {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Vault
    )

    $automationFile = "$(Split-Path $env:DOTFILES)\secrets\automation.xml"
    if (Test-Path $automationFile) {
        $password = Import-Clixml -Path $automationFile
        Unlock-SecretStore -Password $password
    }

    Write-Host "Retrieving secret" -ForegroundColor Blue -NoNewline
    Write-Host " $Name " -ForegroundColor Magenta -NoNewline
    Write-Host "from vault" -ForegroundColor Blue -NoNewline
    Write-Host " $Vault" -ForegroundColor Magenta -NoNewline
    Write-Host "..." -ForegroundColor Blue

    $SecretValue = Get-Secret -Name $Name -Vault $Vault -AsPlainText -ErrorAction SilentlyContinue
    
    
    if (!$SecretValue) {
        $createSecret = Read-Host "No secret found matching $SecretName, create one? (Y/n)"

        if ($createSecret.ToUpper() -eq 'Y') {
            $SecretValue = Read-Host -Prompt "Enter secret value for ($Name)" -AsSecureString
            Set-Secret -Name $Name -Vault $Vault -SecureStringSecret $SecretValue
            if ($?) {
                Write-Host "SUCCESS: Secret" -ForegroundColor Green -NoNewline
                Write-Host " $Name " -ForegroundColor Magenta -NoNewline
                Write-Host "added to vault" -ForegroundColor Green -NoNewline
                Write-Host " $Vault" -ForegroundColor Magenta
            }
            else {
                Write-Error "ERROR: $_"
            }
        }
        else {
            Write-Warning "Secret not found and not created. Exiting..."
            Return
        }
    }
    else {
        return $SecretValue
    }
}