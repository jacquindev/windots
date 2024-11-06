#requires -Module BurntToast
 
function Get-IPAddress {
    <#
    .SYNOPSIS
        Show current public or private IP address of the machine.
    .DESCRIPTION
        Function that enumerate the current public or private IP address.
    .PARAMETER public
        Return the Public (External) IP Address of the current workstation.
    .PARAMETER private
        Return the Private (Internal) IP Address of the current workstation.
    .EXAMPLE
        > Get-IpAddress -public

        Print Public IP Address onto the console.
    .EXAMPLE
        > Get-IpAddress -public -interactive

        Show Public IP Address in Windows notification.
    .NOTES
        Filename: Get-IpAddress.ps1
        Author: Jacquin Moon
        Date: October 15th, 2024

        In order to make it works for Interactive Mode. You must have installed `BurntToast` module.
        For more information about `BurntToast` module, please check the following link:
            -> https://github.com/Windos/BurntToast

        References:
        - https://github.com/mikepruett3/dotposh/blob/master/functions/Get-IPAddress.ps1
        - http://jdhitsolutions.com/blog/friday-fun/4342/friday-fun-whats-my-ip/
        - https://www.technewstoday.com/powershell-get-ip-address/
    #>

    [CmdletBinding()]
    param (
        [switch]$public,
        [switch]$private,
        [switch]$interactive
    )

    Set-Location $PSScriptRoot
    [System.Environment]::CurrentDirectory = $PSScriptRoot

    $LogoPath = "$PSScriptRoot\Assets\global-network.png"

    if ($public) {
        $IPAddress = (Invoke-Webrequest "http://icanhazip.com/" -UseBasicParsing -DisableKeepAlive).Content.Trim()

        if ($interactive) {
            if (!(Get-InstalledModule -Name BurntToast -ErrorAction SilentlyContinue)) {
                Write-Error "Please install BurntToast module to continue!"
            }
            else {
                New-BurntToastNotification -AppLogo $LogoPath -Silent -Text "Public IP Address: ", "`u{1F60A}  $IPAddress"
            }
        }
        else {
            Write-Host "==> " -ForegroundColor "Magenta" -NoNewline
            Write-Host "Public IP Address: " -ForegroundColor "Green"
            Write-Host "`u{1F310}  $IPAddress"
        }
    }

    if ($private) {
        $IPAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $null -ne $_.DHCPEnabled -and $null -ne $_.DefaultIPGateway }).IPAddress | `
            Select-Object -First 1

        if ($interactive) {
            if (!(Get-InstalledModule -Name BurntToast -ErrorAction SilentlyContinue)) {
                Write-Error "Please install BurntToast module to continue!"
            }
            else {
                New-BurntToastNotification -AppLogo $LogoPath -Silent -Text "Local IP Address: ", "`u{1F60A}  $IPAddress"
            }
        }
        else {
            Write-Host "==> " -ForegroundColor "Magenta" -NoNewline
            Write-Host "Local IP Address: " -ForegroundColor "Green"
            Write-Host "`u{1F310}  $IPAddress" 
        }
    }
}

Set-Alias -Name 'ipaddress' -Value 'Get-IPAddress'