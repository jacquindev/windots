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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Name
    )
    Get-ScheduledTask -TaskName $Name | Format-List
}

function Invoke-ScheduledTasks-Running {
    Get-ScheduledTasksInfo -Running
}

function Invoke-ScheduledTasks-Ready {
    Get-ScheduledTasksInfo -Ready
}

function Invoke-ScheduledTasks-Disabled {
    Get-ScheduledTasksInfo -Disabled
}

Set-Alias -Name 'tasks-running' -Value 'Invoke-ScheduledTasks-Running'
Set-Alias -Name 'tasks-ready' -Value 'Invoke-ScheduledTasks-Ready'
Set-Alias -Name 'tasks-disabled' -Value 'Invoke-ScheduledTasks-Disabled'
Set-Alias -Name 'task' -Value 'Get-ScheduledTaskDetail'