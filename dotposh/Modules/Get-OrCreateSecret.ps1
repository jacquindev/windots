#requires -Module Microsoft.PowerShell.SecretManagement
#requires -Module Microsoft.PowerShell.SecretStore

function Get-OrCreateSecret {
    <#
    .SYNOPSIS
        Get secret from local vault or create if it does not exists.
    .DESCRIPTION
        Use external modules: SecretManagement & SecretStore to manage secrets on local machine.
    .PARAMETER SecretName
        Name of the secret to get or create.
    .PARAMETER SecretVault
        Name of the vault where it stores local secrets.
    .EXAMPLE
        Get-OrCreateSecret -SecretName mysecret -SecretVault LocalVault
    .LINK
        https://github.com/scottmckendry/Windots/blob/main/Profile.ps1#L178
        https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
    #>

    [CmdletBinding()]
    param (
        [Alias('n', 'name')][string]$SecretName,
        [Alias('v', 'vault')][string]$SecretVault
    )

    if (!$SecretName) {
        $secretNameList = (Get-SecretInfo).Name
        if ($secretNameList.Count -eq 1) { $SecretName = $secretNameList }
        elseif ($secretNameList.Count -gt 1) {
            if (Get-Command gum -ErrorAction SilentlyContinue) {
                $SecretName = gum choose --header="Choose a Secret Name:" $secretNameList
            } elseif (Get-Command fzf -ErrorAction SilentlyContinue) {
                $SecretName = $secretNameList | fzf --prompt="Select Secret Name >  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
            } else {
                for ($i = 0; $i -lt $secretNameList.Count; $i++) {
                    Write-Host "[$i] $($secretNameList[$i])"
                }
                $index = $(Write-Host "Enter the corresponding number of Secret Name: " -ForegroundColor Magenta -NoNewline; Read-Host)
                if ($null -ne $index) {
                    if ($index -match '^\d+$' -and [int]$index -lt $secretNameList.Count) {
                        $SecretName = $secretNameList[$index]
                    } else { return }
                }
            }
        } else {
            if (Get-Command gum -ErrorAction SilentlyContinue) {
                $SecretName = gum input --prompt="Input Secret Name: "
            } else {
                $SecretName = $(Write-Host "Input Secret Name: " -ForegroundColor Magenta -NoNewline; Read-Host)
            }
        }
    }

    if (!$SecretVault) {
        $secretVaultList = (Get-SecretVault).Name
        if ($secretVaultList.Count -eq 1) { $SecretVault = $secretVaultList }
        elseif ($secretVaultList.Count -gt 1) {
            if (Get-Command gum -ErrorAction SilentlyContinue) {
                $SecretVault = gum choose --header="Choose a Secret Vault:" $secretVaultList
            } elseif (Get-Command fzf -ErrorAction SilentlyContinue) {
                $SecretVault = $secretVaultList | fzf --prompt="Select Secret Vault >  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
            } else {
                for ($j = 0; $j -lt $secretVaultList.Count; $j++) {
                    Write-Host "[$j] $($secretVaultList[$j])"
                }
                $index = $(Write-Host "Enter the corresponding number of Secret Vault: " -ForegroundColor Magenta -NoNewline; Read-Host)
                if ($null -ne $index) {
                    if ($index -match '^\d+$' -and [int]$index -lt $secretVaultList.Count) {
                        $SecretVault = $secretVaultList[$index]
                    } else { return }
                }
            }
        } else {
            if (Get-Command gum -ErrorAction SilentlyContinue) {
                $SecretVault = gum input --prompt="Input Secret Vault name: "
            } else {
                $SecretVault = $(Write-Host "Input Secret Vault name: " -ForegroundColor Magenta -NoNewline; Read-Host)
            }
            Set-SecretStoreConfiguration -Scope CurrentUser -Authentication None -Interaction None -Confirm:$False
            Register-SecretVault -Name $SecretVault -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault:$True
        }
    }

    $SecretValue = Get-Secret -Name $SecretName -Vault $SecretVault -AsPlainText -ErrorAction SilentlyContinue

    if (!$SecretValue) {
        $createSecret = $(Write-Host "No secret found matching $SecretName. Create one? (Y/n) " -ForegroundColor Magenta -NoNewline; Read-Host)

        if ($createSecret.ToUpper() -eq 'Y') {
            $SecretValue = Read-Host -Prompt "Enter secret value for ($SecretName)" -AsSecureString
            Set-Secret -Name $SecretName -Vault $SecretVault -SecureStringSecret $SecretValue
            $SecretValue = Get-Secret -Name $SecretName -AsPlainText -Vault $SecretVault
        } else { throw "Secret not found and not created, exiting" }
    }

    return $SecretValue
}
