function Get-WifiPass {
    [CmdletBinding()]
    param([string]$name = $null)

    if (-not $name) {
        if (Get-Command -Name fzf -ErrorAction SilentlyContinue) {
            $name = netsh wlan show profiles | 
            Select-String -Pattern "All User Profile\s+:\s+(.*)" |
            ForEach-Object { $_.Matches.Groups[1].Value } |
            fzf --prompt="Select Wi-Fi >  " --height=~80% --layout=reverse --border --exit-0 --cycle --margin="2,40" --padding=1
        }
        else {
            Write-Host "LIST OF SAVED WI-FI" -ForegroundColor "Green"
            "`n---`n"
            $wifiList = netsh wlan show profiles | 
            Select-String -Pattern "All User Profile\s+:\s+(.*)" |
            ForEach-Object { $_.Matches.Groups[1].Value }

            for ($i = 0; $i -lt $wifiList.Count; $i++) {
                "{0,5}: {1}" -f ($i + 1), $wifiList[$i]
            }

            "`n---`n"
            $inputPosition = Read-Host "Enter the position number of the Wi-Fi network to check the password (Enter for current network)"
            if ([string]::IsNullOrEmpty($inputPosition)) {
                $name = ((netsh wlan show interfaces | Select-String -Pattern "Profile" -Context 0, 1) -split ":")[1].Trim()
            }
            else {
                $index = [int]$inputPosition - 1
                if ($index -ge 0 -and $index -lt $wifiList.Count) {
                    $name = $wifiList[$index]
                }
                else {
                    Write-Error "Invalid position number."
                    return
                }
            }
        }
    }

    if (-not $name) {
        Write-Host "No input Wi-Fi name" -ForegroundColor "Yellow"
        return
    }

    $wlan_profile = netsh wlan show profile name="$name" key=clear
    $password = $wlan_profile | Select-String -Pattern "Key Content\s+:\s+(.+)" | ForEach-Object { $_.Matches.Groups[1].Value }

    Write-Host "WifiName: " -ForegroundColor "Cyan" -NoNewline
    Write-Host "$name"
    if ($password) {
        Write-Host "Password: " -ForegroundColor "Cyan" -NoNewline
        Write-Host "$password"
    }
    else {
        Write-Host "No password available" -ForegroundColor "Yellow"
    }
}

Set-Alias -Name 'wifipass' -Value 'Get-WifiPass'