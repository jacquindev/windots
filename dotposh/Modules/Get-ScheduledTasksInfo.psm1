function Get-ScheduledTasksInfo {
    param(
        [switch]$Running,
        [switch]$Ready,
        [switch]$Disabled
    )
    if ($Running) {
        Get-ScheduledTask | Where-Object { ($_.State -eq "Running") } |
        Select-Object TaskName, Author, State, URI |
        Sort-Object TaskName | Format-Table -GroupBy State -Property TaskName, URI, Author -AutoSize -Wrap
    }
    if ($Ready) {
        Get-ScheduledTask | Where-Object { ($_.State -eq "Ready") } |
        Select-Object TaskName, Author, State, URI |
        Sort-Object TaskName | Format-Table -GroupBy State -Property TaskName, URI, Author -AutoSize -Wrap
    }
    if ($Disabled) {
        Get-ScheduledTask | Where-Object { ($_.State -eq "Disabled") } |
        Select-Object TaskName, Author, State, URI |
        Sort-Object TaskName | Format-Table -GroupBy State -Property TaskName, URI, Author -AutoSize -Wrap
    }
}

function Get-ScheduledTaskDetail {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )
    Get-ScheduledTask -TaskName $Name | Format-List
}

function Invoke-ScheduledTasksRunning {
    Get-ScheduledTasksInfo -Running
}

function Invoke-ScheduledTasksReady {
    Get-ScheduledTasksInfo -Ready
}

function Invoke-ScheduledTasksDisabled {
    Get-ScheduledTasksInfo -Disabled
}

Set-Alias -Name 'tasks-running' -Value 'Invoke-ScheduledTasksRunning'
Set-Alias -Name 'tasks-ready' -Value 'Invoke-ScheduledTasksReady'
Set-Alias -Name 'tasks-disabled' -Value 'Invoke-ScheduledTasksDisabled'

Export-ModuleMember -Function Get-ScheduledTasksInfo
Export-ModuleMember -Function Get-ScheduledTaskDetail
Export-ModuleMember -Function Invoke-ScheduledTasksRunning, Invoke-ScheduledTasksReady, Invoke-ScheduledTasksDisabled -Alias tasks-running, tasks-ready, tasks-disabled
