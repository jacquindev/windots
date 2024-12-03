# cSpell: disable

<#
.SYNOPSIS
    Helper functions to implement VBoxManage.exe
.NOTES
    Author: Jacquin Moon
    Date: December, Tuesday 03 2024
    Link: https://github.com/jacquindev/windots/blob/main/dotposh/Modules/VBoxManage.ps1
#>

$VBOX_EXEC = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

if (-not (Test-Path -PathType Leaf -Path $VBOX_EXEC)) {
    return 
} 

# Check if gum is installed or not
if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-Warning "Command not found: gum. Please install 'gum' to use this script!"
    return
}

function Get-VBoxManageList {
    param (
        [ArgumentCompletions(
            'bridgedifs', 
            'cloudnets', 
            'cloudprofiles', 
            'cloudproviders', 
            'cpu-profiles', 
            'dhcpservers', 
            'dvds', 
            'extpacks', 
            'floppies', 
            'groups', 
            'hddbackends', 
            'hdds', 
            'hostcpuids', 
            'hostdrives', 
            'hostdvds', 
            'hostfloppies', 
            'hostinfo', 
            'hostonlyifs', 
            'hostonlynets', 
            'intnets', 
            'natnets' , 
            'ostypes', 
            'ossubtypes', 
            'runningvms', 
            'screenshotformats', 
            'systemproperties', 
            'usbfilters', 
            'usbhost', 
            'vms', 
            'webcams'
        )]
        [string]$Subcommand,
        [Alias('l', '-long')][switch]$Detail
    )
    if ($null -ne $Subcommand) {
        if ($Detail) {
            &"$VBOX_EXEC" list --long $Subcommand
        }
        elseif ($Subcommand -eq 'vms') {
            $VMBoxVMs = &"$VBOX_EXEC" list vms
            if ($null -ne $VMBoxVMs) {
                $option = $(Write-Host "Show list of VM Name (y) or UUID (n)? " -ForegroundColor Blue -NoNewline; Read-Host)
                if ($option.ToUpper() -eq 'Y') {
                    $VMBoxVMs = ($VMBoxVMs -replace '"' -replace '{.*').Trim()
                }
                else {
                    $VMBoxVMs = ($VMBoxVMs -replace '.*{' -replace '}').Trim()
                }
                return $VMBoxVms
                Remove-Variable option
            }
            else {
                Write-Warning "No Virtual Machine available! Exiting..."
                Start-Sleep -Seconds 1
                break
            }
        }
        elseif ($Subcommand -eq 'runningvms') {
            $VMBoxVMs = &"$VBOX_EXEC" list runningvms
            if ($null -ne $VMBoxVms) {
                $option = $(Write-Host "Show list of Running VM Name (y) or UUID (n)? " -ForegroundColor Blue -NoNewline; Read-Host)
                if ($option.ToUpper() -eq 'Y') {
                    $VMBoxVMs = ($VMBoxVMs -replace '"' -replace '{.*').Trim()
                }
                else {
                    $VMBoxVMs = ($VMBoxVMs -replace '.*{' -replace '}').Trim()
                }
                return $VMBoxVMs
                Remove-Variable option
            }
            else {
                Write-Warning "No Virtual Machine is running! Exiting..."
                Start-Sleep -Seconds 1
                break
            }
        }
        else {
            &"$VBOX_EXEC" list $Subcommand
        }
    }
    else {
        &"$VBOX_EXEC" list --help
    }
}

function Get-VBoxManageSnapshotList {
    param ([string]$name)
    $snapshots = &"$VBOX_EXEC" snapshot $name list --details
    if (!($snapshots -eq 'This machine does not have any snapshots')) {
        $res = @()
        for ($i = 0; $i -lt $snapshots.Length; $i += 2) {
            $res += $snapshots[$i].Split('Name:').Split('(')[1].Trim() 
        } 
        return $res
    }
    else {
        Write-Warning "No Snapshot available for $name. Exiting..."
        Start-Sleep -Seconds 1
        break
    }
}

function Invoke-VBoxManageSnapshot {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ArgumentCompletions('take', 'delete', 'restore', 'restorecurrent', 'edit', 'list', 'showvminfo')]
        [string]$Subcommand
    )

    function Show-HelpMenu {
        $content = @"
Usage:  Invoke-VBoxManageSnapshot [option]
        Virtual Machine Snapshots Management.

Options: 
    take        --  Take a  virtual machine snapshot
    edit        --  Edit a snapshot name / description
    list        --  List information about a snapshot
    delete      --  Delete a virtual machine snapshot
    restore     --  Revert a virtual machine to a snapshot
    showvminfo  --  Show information about a snapshot

    help        --  Show full message of command 'VBoxManage snapshot'

Example:
    Invoke-VBoxManageSnapshot list
    Invoke-VBoxManageSnapshot showvminfo
"@

        Write-Host "$content"
    }

    if ($PSBoundParameters.Count -eq 0) {
        Show-HelpMenu
    }
    elseif ($Subcommand -eq 'help') {
        &"$VBOX_EXEC" snapshot --help
    }
    else {
        $VMName = gum choose --header="Snapshots Management - Please choose a VM: " $(Get-VBoxManageList vms)
        $SnapshotName = gum choose --header="Snapshots Management - Please choose a Snapshot: " $(Get-VBoxManageSnapshotList $VMName)

        if ($Subcommand -eq 'take') {
            $snapshot = gum input --prompt="Input a Name for your snapshot: " --placeholder="Snapshot 1"
            $desc = gum input --prompt="Write description for your snapshot: " --placeholder="Fresh created and ran once."
            &"$VBOX_EXEC" snapshot "$VMName" take "$snapshot" --description="$desc"
            Remove-Variable desc
        }
        elseif ($Subcommand -eq 'delete') {
            &"$VBOX_EXEC" snapshot "$VMName" delete "$SnapshotName"
        }
        elseif ($Subcommand -eq 'restore') {
            &"$VBOX_EXEC" snapshot "$VMName" restore "$SnapshotName"
        }
        elseif ($Subcommand -eq 'restorecurrent') {
            &"$VBOX_EXEC" snapshot "$VMName" restorecurrent
        }
        elseif ($Subcommand -eq 'edit') {
            $option = $(gum choose --no-limit --header="Snapshots Editor:" "Description" "Name")
            if ($null -ne $option) {
                $desc = gum input --prompt="Write description for your snapshot: " --placeholder="Fresh created and ran once."
                $newname = gum input --prompt="Input a new name for your snapshot: " --placeholder="Ubuntu-December03"
                if ($option.Count -eq 1) {
                    if ($option -eq 'Description') {
                        &"$VBOX_EXEC" snapshot "$VMName" edit "$SnapshotName" --description="$desc"
                    }
                    elseif ($option -eq 'Name') {
                        &"$VBOX_EXEC" snapshot "$VMName" edit "$SnapshotName" --name="$newname"
                    }
                }
                else {
                    &"$VBOX_EXEC" snapshot "$VMName" edit "$SnapshotName" --description="$desc" --name="$newname"
                }
                Remove-Variable desc, newname
            }
            Remove-Variable option
        }
        elseif ($Subcommand -eq 'list') {
            $option = gum choose --header="Snapshots List:" "Details" "Machinereadable"
            if ("$option" -eq "Details") {
                $list = &"$VBOX_EXEC" snapshot "$VMName" list --details
                $list.Trim()
            }
            else {
                $list = &"$VBOX_EXEC" snapshot "$VMName" list --machinereadable
                $list.Trim()
            }
        }
        elseif ($Subcommand -eq 'showinfo') {
            &"$VBOX_EXEC" snapshot "$VMName" showvminfo "$SnapshotName"
        }
        else {
            return
        }
    }
}

function Edit-VBoxManage {
    [CmdletBinding()]
    param (
        [ArgumentCompletions('cpu', 'ram', 'vram', 'disk', 'help')]
        [Parameter(Position = 0)][string]$Subcommand,
        [Parameter(Position = 1)][int]$Size
    )

    function Show-HelpMenu {
        $content = @"
Usage:  Edit-VBoxManage [option] [size]
        Edit Virtual Machine's Disk Size / CPU Number / RAM Amount / Video Memory Amount.

Options:
    disk  --  Change the size of virtual disk
    cpu   --  Change the number of CPU(s) of the virtual machine
    ram   --  Change the amount of RAM (in MB) of the virtual machine
    vram  --  Change the amount of Video Memory (in MB) of the virtual machine
        
    help  --  Show this help menu

Example:
    Edit-VBoxManage ram 4096
    Edit-VBoxManage cpu 2
"@
        Write-Host $content
    }

    if (($PSBoundParameters.Count -eq 0) -or $Subcommand -eq 'help') {
        Show-HelpMenu
    }
    else {
        $VMName = gum choose --header="Modify Virtual Machine - Please choose a VM: " $(Get-VBoxManageList vms)
        if ($Subcommand -eq 'cpu') {
            &"$VBOX_EXEC" modifyvm "$VMName" --cpus $Size
        }
        elseif ($Subcommand -eq 'ram') {
            &"$VBOX_EXEC" modifyvm "$VMName" --memory $Size
        }
        elseif ($Subcommand -eq 'vram') {
            &"$VBOX_EXEC" modifyvm "$VMName" --vram $Size
        }
        elseif ($Subcommand -eq 'disk') {
            &"$VBOX_EXEC" modifymedium disk "$VMName" --resize $Size
        }
    }
}

function Update-VBoxManage {
    [CmdletBinding()]
    param (
        [ArgumentCompletions('help', 'perform', 'list', 'modify')]
        [string]$Subcommand,
        
        [Alias('-machine-readable', 'r')][switch]$readable,
        [Alias('-disable')][switch]$off,
        [Alias('-enable')][switch]$on,

        [ArgumentCompletions('stable', 'beta', 'all')]
        [Alias('-channel')]
        [string]$c,

        [Alias('-frequency', '--days')]
        [int]$d,

        [ArgumentCompletions('system', 'manual', 'none')]
        [Alias('-proxy-mode')]
        [string]$m,

        [Alias('-proxy-url')]
        [string]$u
    )

    function Show-HelpMenu {
        $content = @"
Usage:  Update-VBoxManage [option] [args...]
        Checks for a newer version of Oracle VirtualBox.

Options:
    perform --  Check for available new version of Oracle VirtualBox
    list    --  Displays current settings used for checking newer version of VirtualBox
    modify  --  Modify settings used for checking newer version of VirtualBox

    help    --  Show full message of command 'VBoxManage updatecheck'

Parameters:
    -r, --machine-readable                -- Machine readable output (only: perform, list)
    -d, --frequency, --days               -- Days to check for a newer version (only: modify) 
    -c, --channel [stable|beta|all]       -- Release type of newer version (only: modify)
    -m, --proxy-mode [system|manual|none] -- Specify the proxy mode (only: modify)
    -u, --proxy-url                       -- Specify the proxy address (only: modify)
    -on,  --enable                        -- Enable the update check service (only: modify)
    -off, --disable                       -- Disable the update check service (only: modify)

Example:
    Update-VBoxManage perform -readable
    Update-VBoxManage modify --channel beta
"@

        Write-Host $content
    }

    if ($PSBoundParameters.Count -eq 0) {
        Show-HelpMenu
    }
    else {
        if ($Subcommand -eq 'help') {
            &"$VBOX_EXEC" updatecheck --help
        }
        elseif ($Subcommand -eq 'perform') {
            if ($readable) {
                &"$VBOX_EXEC" updatecheck perform --machine-readable
            }
            else {
                &"$VBOX_EXEC" updatecheck perform
            }
        }
        elseif ($Subcommand -eq 'list') {
            if ($readable) {
                &"$VBOX_EXEC" updatecheck list --machine-readable
            }
            else {
                &"$VBOX_EXEC" updatecheck list
            }
        }
        elseif ($Subcommand -eq 'modify') {
            if ($on) { &"$VBOX_EXEC" updatecheck modify --enable }
            elseif ($off) { &"$VBOX_EXEC" updatecheck modify --disable }
            elseif ("$c" -eq 'stable') { &"$VBOX_EXEC" updatecheck modify --channel=stable }
            elseif ("$c" -eq 'beta') { &"$VBOX_EXEC" updatecheck modify --channel=withbetas }
            elseif ("$c" -eq 'all') { &"$VBOX_EXEC" updatecheck modify --channel=all }
            elseif ($null -ne $d) { &"$VBOX_EXEC" updatecheck modify --frequency="$days" }
            elseif ("$m" -eq 'system') { &"$VBOX_EXEC" updatecheck modify --proxy-mode=system }
            elseif ("$m" -eq 'manual') { &"$VBOX_EXEC" updatecheck modify --proxy-mode=manual }
            elseif ("$m" -eq 'none') { &"$VBOX_EXEC" updatecheck modify --proxy-mode=none }
            elseif ($null -ne $u) { &"$VBOX_EXEC" updatecheck modify --proxy-url="$proxyUrl" }
        }
        else { return }
    }
}

function Invoke-VBoxManageGuest {
    [CmdletBinding()]
    param (
        [ArgumentCompletions('help', 'run', 'start', 'copyfrom', 'copyto', 'mkdir', 'rmdir', 'rm', 'mv', 'mktemp', 'mount', 'fsinfo', 'stat', 'list', 'closeprocess', 'closesession', 'updatega', 'waitrunlevel', 'watch')]
        [string]$Subcommand
    )

    function Show-HelpMenu {
        $contents = @"
Usage:  Invoke-VBoxManageGuest [option] [args...]
        Control a virtual machine from the host system.

Options:
    run          --  Run a Command in the guest
    start        --  Start a Command on the guest
    copyfrom     --  Copy a file from the guest to the host
    copyto       --  Copy a file from the host to the guest
    mkdir        --  Create a directory on the guest
    rmdir        --  Remove a directory from the guest
    rm           --  Remove a file from the guest
    mv           --  Rename a file or Directory on the guest
    mktemp       --  Create a Temporary File or Directory on the guest
    mount        --  Shows mount points on the guest
    fsinfo       --  Show guest filesystem information
    stat         --  Show a file or File System Status on the guest
    list         --  List the Configuration and Status Information for a Guest Virtual Machine
    closeprocess --  Terminate a Process in a guest Session
    closesession --  Close a guest Session
    updatega     --  Update the Guest Additions Software on the guest
    waitrunlevel --  Wait for a guest run level
    watch        --  Show Current Guest Control Activity

    help         --  Show detailed help message from 'VBoxManage guestcontrol'

Example:
    Invoke-VBoxManageGuest start --exe "c:\\windows\\system32\\ipconfig.exe" --username user1
"@
        Write-Host $contents
    }

    if ($PSBoundParameters.Count -eq 0) {
        Show-HelpMenu
    }
    elseif ($Subcommand -eq 'help') { &"$VBOX_EXEC" guestcontrol --help }
    else {
        $VMName = gum choose --header="Guest Control - Please choose a VM: " $(Get-VBoxManageList vms)
        if ($Subcommand -eq 'run') { &"$VBOX_EXEC" guestcontrol "$VMName" run $args }
        elseif ($Subcommand -eq 'start') { &"$VBOX_EXEC" guestcontrol "$VMNAME" start $args }
        elseif ($Subcommand -eq 'copyfrom') { &"$VBOX_EXEC" guestcontrol "$VMNAME" copyfrom $args }
        elseif ($Subcommand -eq 'copyto') { &"$VBOX_EXEC" guestcontrol "$VMNAME" copyto $args }
        elseif ($Subcommand -eq 'mkdir') { &"$VBOX_EXEC" guestcontrol "$VMNAME" mkdir $args }
        elseif ($Subcommand -eq 'rmdir') { &"$VBOX_EXEC" guestcontrol "$VMNAME" rmdir $args }
        elseif ($Subcommand -eq 'rm') { &"$VBOX_EXEC" guestcontrol "$VMNAME" rm $args }
        elseif ($Subcommand -eq 'mv') { &"$VBOX_EXEC" guestcontrol "$VMNAME" mv $args }
        elseif ($Subcommand -eq 'mktemp') { &"$VBOX_EXEC" guestcontrol "$VMNAME" mktemp $args }
        elseif ($Subcommand -eq 'mount') { &"$VBOX_EXEC" guestcontrol "$VMNAME" mount $args }
        elseif ($Subcommand -eq 'fsinfo') { &"$VBOX_EXEC" guestcontrol "$VMNAME" fsinfo $args }
        elseif ($Subcommand -eq 'stat') { &"$VBOX_EXEC" guestcontrol "$VMNAME" stat $args }
        elseif ($Subcommand -eq 'list') { &"$VBOX_EXEC" guestcontrol "$VMNAME" list $args }
        elseif ($Subcommand -eq 'closeprocess') { &"$VBOX_EXEC" guestcontrol "$VMNAME" closeprocess $args }
        elseif ($Subcommand -eq 'closesession') { &"$VBOX_EXEC" guestcontrol "$VMNAME" closesession $args }
        elseif ($Subcommand -eq 'updatega') { &"$VBOX_EXEC" guestcontrol "$VMNAME" updatega $args }
        elseif ($Subcommand -eq 'waitrunlevel') { &"$VBOX_EXEC" guestcontrol "$VMNAME" waitrunlevel $args }
        elseif ($Subcommand -eq 'watch') { &"$VBOX_EXEC" guestcontrol "$VMNAME" watch $args }
        else { return }
    }
}

function Set-VBoxManageExtPack {
    [CmdletBinding()]
    param (
        [ArgumentCompletions('install', 'uninstall', 'cleanup', 'list')]
        [string]$Subcommand,

        [Alias('-replace')][switch]$r,
        [Alias('-force')][switch]$f,
        [Alias('n')][string]$Name
    )

    function Show-HelpMenu {
        $content = @"
Usage:  Set-VBoxManageExtPack [option] [args...]
        Extension package management.

Options:
    cleanup    --  Clean temporary files / directories
    list       --  List all installed extension packs
    install    --  Install an extension pack for the system
    uninstall  --  Uninstall an extension pack from the system

    help       --  Show full message of command 'VBoxManage extpack'

Parameters:
    -r, --replace --  Uninstall existed extpack before installing new one (only: install)
    -f, --force   --  Overrides most refusals to uninstall an extension pack (only: uninstall)

Example:
    Set-VBoxManageExtPack install --replace <tarball>
    Set-VBoxManageExtPack uninstall --force <name>
"@

        Write-Host $content
    }

    if ($PSBoundParameters.Count -eq 0) {
        Show-HelpMenu
    }
    elseif ($Subcommand -eq 'help') {
        &"$VBOX_EXEC" extpack --help
    }
    else {
        if ($Subcommand -eq 'install') {
            if ($r) {
                &"$VBOX_EXEC" extpack install --replace $Name 
            }
            else {
                &"$VBOX_EXEC" extpack install $Name 
            }
        }
        elseif ($Subcommand -eq 'uninstall') {
            if ($f) {
                &"$VBOX_EXEC" extpack uninstall --force $Name 
            }
            else {
                &"$VBOX_EXEC" extpack uninstall $Name 
            }
        }
        elseif ($Subcommand -eq 'list') {
            Get-VBoxManageList extpacks
        }
        elseif ($Subcommand -eq 'cleanup') {
            &"$VBOX_EXEC" extpack cleanup
        }
    }
}

function Invoke-VBoxManage {
    [CmdletBinding()]
    param(
        [ArgumentCompletions('help', 'commands', 'extpack', 'version', 'list', 'edit', 'start', 'stop', 'delete', 'snapshot', 'guestcontrol', 'update')]
        [string]$Subcommand
    )

    function Show-HelpMenu {
        $contents = @"
Usage:  Invoke-VBoxManage [option]

Options:
    commands     --  Print all available command for 'VBoxManage'
    delete       --  Delete a virtual machine
    edit         --  Edit VM's CPU(s), RAM, VRAM, and Disk Size
    extpack      --  Extension package management
    guestcontrol --  Control a virtual machine from the host system
    list         --  View system information and VM configuration details
    snapshot     --  Snapshots Management for a virtual machine
    start        --  Start a virtual machine
    stop         --  Stop a virtual machine
    update       --  Check for a newer version of Oracle VirtualBox
    version      --  Print current Oracle VirtualBox version

    help         --  Print full help message of command 'VBoxManage'

Example:
    Invoke-VBoxManage commands
    Invoke-VBoxManage update
"@

        Write-Host $contents
    }

    # Main part
    if ($PSBoundParameters.Count -eq 0) {
        Show-HelpMenu
    }
    elseif ($Subcommand -eq 'help') {
        &"$VBOX_EXEC" help $args
    }
    elseif ($Subcommand -eq 'commands') {
        &"$VBOX_EXEC" commands
    }
    elseif ($Subcommand -eq 'version') {
        &"$VBOX_EXEC" --version
    }
    elseif ($Subcommand -eq 'list') {
        Get-VBoxManageList vms
    }
    elseif ($Subcommand -eq 'start') {
        $option = $(gum choose --header="Choose a VM to START:" $(Get-VBoxManageList vms))
        &"$VBOX_EXEC" startvm $option --type headless
        Remove-Variable option
    }
    elseif ($Subcommand -eq 'stop') {
        $option = $(gum choose --header="Choose a VM to STOP:" $(Get-VBoxManageList runningvms))
        &"$VBOX_EXEC" controlvm $option poweroff
        Remove-Variable option
    }
    elseif ($Subcommand -eq 'delete') {
        $option = $(gum choose --header="Choose a VM to DELETE:" $(Get-VBoxManageList vms))
        &"$VBOX_EXEC" unregistervm $option --delete
        Remove-Variable option
    }
    elseif ($Subcommand -eq 'snapshot') {
        Invoke-VBoxManageSnapshot @args
    }
    elseif ($Subcommand -eq 'edit') {
        Edit-VBoxManage @args
    }
    elseif ($Subcommand -eq 'update') {
        Update-VBoxManage @args
    }
    elseif ($Subcommand -eq 'guestcontrol') {
        Invoke-VBoxManageGuest @args
    }
    elseif ($Subcommand -eq 'extpack') {
        Set-VBoxManageExtPack @args
    }
    else {
        &"$VBOX_EXEC" $args
    }
}

Set-Alias -Name 'vboxmanage' -Value 'Invoke-VBoxManage'
Set-Alias -Name 'vboxmanage-list' -Value 'Get-VBoxManageList'
Set-Alias -Name 'vboxmanage-snapshot' -Value 'Invoke-VBoxManageSnapshot'
Set-Alias -Name 'vboxmanage-edit' -Value 'Edit-VBoxManage'
Set-Alias -Name 'vboxmanage-update' -Value 'Update-VBoxManage'
Set-Alias -Name 'vboxmanage-guestcontrol' -Value 'Invoke-VBoxManageGuest'
Set-Alias -Name 'vboxmanage-extpack' -Value 'Set-VBoxManageExtPack'