function Write-AnimatedProgress {
    <#
    .SYNOPSIS
        Show animated animations while waiting for progress done.
    .NOTES
        References: 
        - https://github.com/Jaykul/Spinner/blob/master/Spinner.ps1
        - https://github.com/DBremen/Write-TerminalProgress/blob/main/Write-TerminalProgress.ps1
        - https://github.com/sindresorhus/cli-spinners/blob/07c83e7b9d8a08080d71ac8bda2115c83501d9d6/spinners.json
    #>
    [CmdletBinding()]
    param (
        [string]$SpinnerName = "earth",
        [string]$Label = "",
        [string[]]$Frames,
        [int]$Interval = 80,
        [int]$Duration = 10
    )

    $e = [char]27
    $Sw = [System.Diagnostics.Stopwatch]::new()
    $Sw.Start()
    $Duration *= 500

    Set-Location $PSScriptRoot
    [System.Environment]::CurrentDirectory = $PSScriptRoot

    if ($SpinnerName) {
        $spinnersPath = "$PSScriptRoot\Assets\spinners.json"
        $spinners = Get-Content $spinnersPath | ConvertFrom-Json -AsHashtable
        $spinner = $spinners[$SpinnerName]
        $Interval = $spinner["interval"]
        $Frames = $spinner["frames"]
    }

    $Frames = $Frames.ForEach{ "$e[u" + $_ + " " + $Label }
    Write-Host "$e[s" -NoNewline

    do {
        foreach ($Frame in $Frames) {
            Write-Host $Frame -NoNewline
            Start-Sleep -Milliseconds $Interval
        }
    } while ($Sw.ElapsedMilliseconds -lt $Duration)

    Write-Host ("$e[u" + (" " * ($Frame.Length + $Label.Length + 1)) + "$e[u") -NoNewline
    $Sw.Stop()
}

function Get-Netstats {
    <#
        .SYNOPSIS
            Retrieves Network Connections
        .DESCRIPTION
            Function that emulates the MS-DOS netstat tool, and returns a PSCustomObject
            that includes resultes in a specified format.
        .PARAMETER Listen
            Returns all Network Connections with the state of 'Listening'
        .PARAMETER Process
            Returns all Network Connections that match the 'Process' name
        .PARAMETER ID
            Returns all Network Connections that match the Process 'ID'
        .PARAMETER LocalPort
            Returns all Network Connections that match the Local Port number
        .PARAMETER RemotePort
            Returns all Network Connections that match the Remote Port number
        .PARAMETER Process
            Returns all Network Connections that match the 'Process' name
        .EXAMPLE
            > Get-Netstats -Listen
                or
            > Get-Netstats -Process svchost
                or
            > Get-Netstats -RemotePort 443
        .NOTES
            This function was originally from Mike Pruett, please check the file below for more details: 
                - https://github.com/mikepruett3/dotposh/blob/master/functions/Get-Netstat.ps1
    
            I rewrite this with the purpose of simplifying the code and adding extra waiting animations.
        #>
    [CmdletBinding()]
    param (
        [switch] $Listen,
        [string] $Process,
        [string] $ID,
        [string] $LocalPort,
        [string] $RemotePort
    )
    
    $Results = @()
    
    if ($PSBoundParameters.Count -eq 0) {
        Write-AnimatedProgress -Label "Collecting TCP & UDP connections ..."
        $TCPConnections = Get-NetTCPConnection -ErrorAction SilentlyContinue
        $UDPConnections = Get-NetUDPEndpoint -ErrorAction SilentlyContinue
        $Sort = "LocalAddress"
    }
    
    if ($Listen) {
        Write-AnimatedProgress -Label "Collecting TCP Connections of Listening State ..."
        $TCPConnections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
        $Sort = "LocalAddress"
    }
    
    if ($Process) {
        Write-AnimatedProgress -Label "Collecting TCP & UDP Connections of Process Name - $Process ..."
        $ProcessId = (Get-Process -Name $Process -ErrorAction SilentlyContinue).Id
        $TCPConnections = Get-NetTCPConnection -OwningProcess $ProcessId -ErrorAction SilentlyContinue
        $UDPConnections = Get-NetUDPEndpoint -OwningProcess $ProcessId -ErrorAction SilentlyContinue
        $Sort = "LocalAddress"
    }
    
    if ($ID) {
        Write-AnimatedProgress -Label "Collecting TCP & UDP Connections of Process ID - $ID ..."
        $TCPConnections = Get-NetTCPConnection -OwningProcess $ID -ErrorAction SilentlyContinue
        $UDPConnections = Get-NetUDPEndpoint -OwningProcess $ID -ErrorAction SilentlyContinue
        $Sort = "LocalAddress"
    }
    
    if ($LocalPort) {
        Write-AnimatedProgress -Label "Collecting TCP & UDP Connections of Local Port - $LocalPort ..."
        $TCPConnections = Get-NetTCPConnection -LocalPort $LocalPort -ErrorAction SilentlyContinue
        $UDPConnections = Get-NetUDPEndpoint -LocalPort $LocalPort -ErrorAction SilentlyContinue
        $Sort = "ProcessName"
    }
    
    if ($RemotePort) {
        Write-AnimatedProgress -Label "Collecting TCP Connections of Remote Port - $RemotePort ..."
        $TCPConnections = Get-NetTCPConnection -RemotePort $RemotePort -ErrorAction SilentlyContinue
        $Sort = "ProcessName"
    }
    
    foreach ($Connection in $TCPConnections) {
        $Result = [PSCustomObject]@{
            CreationTime = $Connection.CreationTime
            ID           = $Connection.OwningProcess
            LocalAddress = $Connection.LocalAddress
            LocalPort    = $Connection.LocalPort
            OffloadState = $Connection.OffloadState
            ProcessName  = (Get-Process -Id $Connection.OwningProcess -ErrorAction SilentlyContinue).ProcessName
            Protocol     = "TCP"
            RemotePort   = $Connection.RemotePort
            State        = $Connection.State
        }
    
        if (Resolve-DNSName -Name $Connection.RemoteAddress -DnsOnly -ErrorAction SilentlyContinue) {
            $Result | Add-Member -MemberType NoteProperty -Name "RemoteAddress" -Value (Resolve-DNSName -Name $Connection.RemoteAddress -DnsOnly).NameHost
        }
        else {
            $Result |  Add-Member -MemberType NoteProperty -Name 'RemoteAddress' -Value $Connection.RemoteAddress
        }
    
        $Results += $Result
    }
    
    foreach ($Connection in $UDPConnections) {
        $Result = [PSCustomObject]@{
            CreationTime  = $Connection.CreationTime
            ID            = $Connection.OwningProcess
            LocalAddress  = $Connection.LocalAddress
            LocalPort     = $Connection.LocalPort
            OffloadState  = $Connection.OffloadState
            ProcessName   = (Get-Process -Id $Connection.OwningProcess -ErrorAction SilentlyContinue).ProcessName
            Protocol      = "UDP"
            RemoteAddress = $Connection.RemoteAddress
            RemotePort    = $Connection.RemotePort
            State         = $Connection.State
        }
        $Results += $Result
    }
    
    $Results |
    Select-Object Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, ProcessName, ID |
    Sort-Object -Property @{Expression = "Protocol" }, @{Expression = $Sort } |
    Format-Table -AutoSize -Wrap
} 

Set-Alias -Name 'netstats' -Value 'Get-Netstats'