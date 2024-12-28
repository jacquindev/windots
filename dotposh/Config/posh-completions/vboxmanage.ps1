if ((-not (Get-Command VBoxManage.exe -ErrorAction SilentlyContinue)) -and (Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe")) {
    function VBoxManage {
        &"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" @args
    }
    Set-Alias -Name 'vbm' -Value 'VBoxManage'
}

# TODO: Add completions for subcommands' params
##################################################################################################
# $script:VBMCommands = (VBoxManage commands | sed -n '1!p').Trim() + 'help' + 'commands' -split ' '
# $script:VBMUuids = ((VBoxManage list vms) -replace '.*{' -replace '}.*').Trim()
# $script:VBMVmnames = ((VBoxManage list vms) -replace '"' -replace '{.*' ).Trim()
# $script:VBMVmNamesWithCommands = @(
#     'adopstate', 'bandwidthctl', 'checkmediumpwd', 'clonevm', 'debugvm', 'discardstate', 'encryptvm', 'guestcontrol',
#     'modifynvram', 'modifyvm', 'movevm', 'showvminfo', 'snapshot', 'storageattach', 'storagectl', 'unregistervm', 'controlvm'
# )
# $script:VBMSubcommands = @{
#     closemedium    = 'disk dvd floppy' # <uuid>
#     convertfromraw = 'stdin'
#     createmedium   = 'disk dvd floppy'
#     debugvm        = 'guestsample statistics stack show setregisters getregisters osdmesg osinfo logflags logdest log injectnmi info dumpvmcore'
#     dhcpserver     = 'remove start restart stop findlease modify add'
#     extpack        = 'install uninstall cleanup'
#     guestproperty  = 'wait unset set get enumerate'
#     hostonlyif     = 'create remove ipconfig'
#     hostonlynet    = 'add modify remove'
#     mediumproperty = 'disk dvd floppy'
#     metrics        = 'collect disable enable list query setup'
#     modifymedium   = 'disk dvd floppy'
#     natnetwork     = 'add list remove start stop'
#     sharedfolder   = 'remove modify add'
#     showmediuminfo = 'disk dvd floppy' # <uuid>
#     updatecheck    = 'perform list modify'
#     usbdevsource   = 'add remove'
#     usbfilter      = 'remove modify add'

#     cloud          = 'list instance image network'
#     bandwidthctl   = 'add list remove set'
#     clonemedium    = 'disk dvd floppy'
#     guestcontrol   = 'updatega closesession closeprocess list stat fsinfo mount mktemp mv rm rmdir watch copyfrom copyto start run'
#     modifynvram    = 'inituefivarstore enrollmssignatures enrollorclpk enrollpk enrollmok secureboot listvars queryvar deletevar changevar'
# }

# $script:VBMSubcommandWithParams = @{
#     extpack      = @{
#         install   = 'replace accept-license=sha256'
#         uninstall = 'force'
#     }
#     createmedium = @{
#         disk   = 'filename size sizebyte diffparent format=VDI format=VMDK format=VHD variant=Standard variant=Fixed variant=Split2G variant=Stream variant=ESX variant=Formatted variant=RawDisk property property-file'
#         dvd    = 'filename size sizebyte diffparent format=VDI format=VMDK format=VHD variant=Standard variant=Fixed variant=Split2G variant=Stream variant=ESX variant=Formatted variant=RawDisk property property-file'
#         floppy = 'filename size sizebyte diffparent format=VDI format=VMDK format=VHD variant=Standard variant=Fixed variant=Split2G variant=Stream variant=ESX variant=Formatted variant=RawDisk property property-file'
#     }
#     dhcpserver   = @{
#         remove    = 'network interface'
#         start     = 'network interface'
#         restart   = 'network interface'
#         stop      = 'network interface'
#         findlease = 'network interface mac-address'
#         modify    = 'network interface mac-address server-ip netmask lower-ip upper-ip enable disable global group vm mac-address'
#         add       = 'network interface mac-address server-ip netmask lower-ip upper-ip enable disable global group vm mac-address'
#     }
#     hostonlynet  = @{
#         add    = 'name id netmask lower-ip upper-ip enable disable'
#         modify = 'name id netmask lower-ip upper-ip enable disable'
#         remove = 'name id'
#     }
#     unattended   = @{
#         detect = 'iso machine-readable'
#     }
#     natnetwork   = @{
#         add    = 'disable enable netname network dhcp=on dhcp=off ipv6=on ipv6=off loopback-4 loopback-6 port-forward-4 port-forward-6'
#         modify = 'disable enable netname network dhcp=on dhcp=off ipv6=on ipv6=off loopback-4 loopback-6 port-forward-4 port-forward-6'
#         remove = 'netname'
#         start  = 'netname'
#         stop   = 'netname'
#     }
# }

# $script:VBMSubcommandWithParamKeys = $VBMSubcommandWithParams.Keys -join '|'

# function script:VBMExpandCmd($filter) {
#     $vbcmds = @()
#     $vbcmds += $VBMCommands
#     $vbcmds -like "$filter*" | Sort-Object
# }

# function script:VBMNamesOrUuids($filter, $onlyUuids) {
#     $VmNames = @()
#     if ($onlyUuids) { $VmNames += $VBMUuids }
#     else { $VmNames += $VBMVmnames + $VBMUuids }

#     $VmNames -like "$filter*" | Sort-Object
# }


# function script:VBMExpandParamValues($cmd, $param, $filter) {
#     $VBMSubcommandWithParams[$cmd][$param] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object | ForEach-Object { -join ("--", $_) }
# }

# function script:VBMListCmd($filter) {
#     $params = @('long', 'platform-arch=x86', 'platform-arch=arm', 'sorted') | Sort-Object | ForEach-Object { -join ("--", $_) }
#     $cmds = @(
#         'bridgedifs', 'cloudnets', 'cloudprofiles', 'cloudproviders', 'cpu-profiles', 'dhcpservers',
#         'dvds', 'extpacks', 'floppies', 'groups', 'hddbackends', 'hdds', 'hostcpuids', 'hostdrives',
#         'hostdvds', 'hostfloppies', 'hostinfo', 'hostonlyifs', 'hostonlynets', 'intnets', 'natnets',
#         'ostypes', 'ossubtypes', 'runningvms', 'screenshotformats', 'systemproperties', 'usbfilters',
#         'usbhost', 'vms', 'webcams'
#     )
#     $values = $params + $cmds
#     $values -split ' ' | Sort-Object | Where-Object { $_ -like "$filter*" }
# }

# function script:VBMMediumIoCmd($filter) {
#     $params = @('disk', 'dvd', 'floppy', 'password-file') | Sort-Object | ForEach-Object { -join ("--", $_) }
#     $cmds = @('formatfat', 'cat', 'stream')
#     $values = $params + $cmds
#     $values -split ' ' | Sort-Object | Where-Object { $_ -like "$filter*" }
# }

# function script:VBMExpandCmdParam($cmds, $cmd, $filter) {
#     $cmds.$cmd -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object
# }

# function script:VBMTabExpansion($block) {
#     switch -regex ($block) {
#         # VBoxManage <cmd> <subcmd> --<param>
#         "^(?<cmd>$VBMSubcommandWithParamKeys).* (?<subcmd>.+) --(?<param>\w*)$" {
#             if ($VBMSubcommandWithParams[$matches['cmd']][$matches['subcmd']]) {
#                 return VBMExpandParamValues $matches['cmd'] $matches['subcmd'] $matches['param']
#             }
#         }

#         # VBoxmanage <cmd> <uuid|vmname>
#         "^($($VBMVmNamesWithCommands -join '|'))\s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['vmname'] $false
#         }

#         # VBoxmanage <cmd> <uuid>
#         "^(clonemedium|encryptmedium)\s+(?:.+\s+)?(?<uuid>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['uuid'] $true
#         }

#         # VBoxmanage [setextradata|getextradata] <uuid|vmname|global>
#         "^(setextradata|getextradata)\s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return (VBMNamesOrUuids $matches['vmname'] $false) + @('global') -split ' '
#         }

#         # VBoxManage list <subcmd>|--<param>
#         "^list\s+(?:.+\s+)?(?<subcmd>[\w][\-\.\w]*)?$" {
#             return VBMListCmd $matches['subcmd']
#         }

#         # VBoxManage [modifymedium|closemedium] [disk|dvd|floppy] <uuid|vmname>
#         "^(modifymedium|closemedium) (disk|dvd|floppy)\s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['vmname'] $false
#         }

#         # VBoxManage guestproperty <subcmd> <uuid|vmname>
#         "^guestproperty (get|enumerate|set|unset|wait)\s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['vmname'] $false
#         }

#         # VBoxManage unattended install <uuid|vmname>
#         "^unattended install\s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['vmname'] $false
#         }

#         # VBoxManage mediumio --<param> <subcmd>
#         "^mediumio\s+(?:.+\s+)?(?<subcmd>[\w][\-\.\w]*)?$" {
#             return VBMMediumIoCmd $matches['subcmd']
#         }

#         # VBoxManage sharedfolder <subcmd> <uuid|vmname>
#         "^sharedfolder (add|remove|modify) \s+(?:.+\s+)?(?<vmname>[\w][\-\.\w]*)?$" {
#             return VBMNamesOrUuids $matches['vmname'] $false
#         }

#         # VBoxManage <cmd> <subcommand>
#         "^(?<cmd>$($VBMSubcommands.Keys -join '|'))\s+(?<op>\S*)$" {
#             return VBMExpandCmdParam $VBMSubcommands $matches['cmd'] $matches['op']
#         }

#         # VBoxManage help <cmd>
#         "^help (?<cmd>\S*)$" { return VBMExpandCmd $matches['cmd'] }

#         # VBoxManage <cmd>
#         "^(?<cmd>\S*)$" { return VBMExpandCmd $matches['cmd'] }
#     }
# }


# Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
#     Register-ArgumentCompleter -CommandName @('VBoxManage.exe', 'VBoxManage', 'vboxmanage', 'vbm') -ScriptBlock {
#         param ($wordToComplete, $commandAst, $cursorColumn)
#         $argList = $commandAst.CommandElements[1..$commandAst.CommandElements.Count] -join ' '
#         if ($argList -ne "" -and $wordToComplete -eq "") {
#             $argList += " "
#         }

#         VBMTabExpansion $argList
#     }
# } | Out-Null
