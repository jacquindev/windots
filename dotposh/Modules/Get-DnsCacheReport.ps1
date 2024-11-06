function Get-DnsCacheReport {
    <#
    .LINK
        https://raw.githubusercontent.com/HarmVeenstra/Powershellisfun/refs/heads/main/Create%20a%20Report%20on%20DNS%20lookups/Get-DnsCacheReport.ps1
    #>
    param (
        [Parameter(Mandatory = $true)][int]$Minutes,
        [Parameter(Mandatory = $false)][string]$CsvPath
    )

    # Set script root directory to ensure relative paths work correctly
    Set-Location $PSScriptRoot
    [System.Environment]::CurrentDirectory = $PSScriptRoot

    # Spinner up a background job to periodically update DNS cache
    $origpos = $host.UI.RawUI.CursorPosition
    $spinner = (Get-Content "$env:DOTPOSH\Modules\Assets\spinners.json" | ConvertFrom-Json -AsHashTable).moon.frames
    $spinnerPos = 0

    $t = New-TimeSpan -Minute $Minutes
    $remain = $t
    $d = (Get-Date) + $t
    [int]$Interval = 1

    # Start countdown 
    while ($remain.TotalSeconds -gt 0) {
        Write-Host (" {0} " -f $spinner[$spinnerPos % ($spinner.Count)]) -NoNewline
        Write-Host "Gathering DNS Cache Information, countdown:" -ForegroundColor "Green" -NoNewline
        Write-Host (" {0} days {1:d2}:{2:d2}:{3:d2} " -f $remain.Days, $remain.Hours, $remain.Minutes, $remain.Seconds) -ForegroundColor "Yellow" -NoNewline
        Write-Host "remaining..." -ForegroundColor "Green" -NoNewline

        $Host.UI.RawUI.CursorPosition = $origpos
        $spinnerPos += 1
        Start-Sleep -Seconds $Interval

        # Get DNS cache information and update remaining time
        $dnscache = Get-DnsClientCache
        $result = foreach ($item in $dnscache) {
            [PSCustomObject]@{
                Entry      = $item.Entry
                RecordType = (Get-DnsRecordType $item.Type)
                Status     = (Get-DnsStatus $item.Status)
                Section    = (Get-DnsSection $item.Section)
                Target     = $item.Data
            }
        }
        $remain = ($d - (Get-Date))
    }
    Write-Host "Finished gathering DNS Cache Information" -ForegroundColor "Green"
    if ($CsvPath) {
        Write-Host "Saved results into $CsvPath" -ForegroundColor "Cyan"
        $result | Export-Csv -Path $CsvPath -Encoding utf8 -Delimiter ';' -NoTypeInformation -Force
    }
    $result | Sort-Object Entry | Format-Table
}

function Get-DnsRecordType($type) {
    switch ($type) {
        1 { return 'A' }
        2 { return 'NS' }
        5 { return 'CNAME' }
        6 { return 'SOA' }
        12 { return 'PTR' }
        15 { return 'MX' }
        28 { return 'AAAA' }
        33 { return 'SRV' }
        default { return 'Unknown' }
    }
}

function Get-DnsStatus($status) {
    switch ($status) {
        0 { return 'Success' }
        9003 { return 'NotExist' }
        9501 { return 'NoRecords' }
        9701 { return 'NoRecords' }
        default { return 'Unknown' }
    }
}

function Get-DnsSection($section) {
    switch ($section) {
        1 { return 'Answer' }
        2 { return 'Authority' }
        3 { return 'Additional' }
        default { return 'Unknown' }
    }
}