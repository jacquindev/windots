# cSpell: disable

if (!(Get-Command VBoxManage -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe") {
        function VBoxManage {
            &"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" $args
        }
    }
    else { return }
}

$script:VBoxManageCommands = @(
    'adoptstate',
    'bandwidthctl',
    'checkmediumpwd',
    'clonemedium',
    'clonevm',
    'closemedium',
    'cloud',
    'cloudprofile',
    'commands',
    'controlvm',
    'convertfromraw',
    'createmedium',                                                                                    
    'createvm',
    'debugvm',
    'dhcpserver',
    'discardstate',
    'encryptmedium',
    'encryptvm',
    'export',
    'extpack',
    'getextradata',
    'guestcontrol',
    'guestproperty',
    'help',
    'hostonlyif',
    'import',
    'internalcommands',
    'list',                                                                                            
    'mediumio',
    'mediumproperty',
    'metrics',
    'modifymedium',
    'modifynvram',
    'modifyvm',
    'movevm',
    'natnetwork',
    'registervm',
    'setextradata',
    'setproperty',
    'sharedfolder',
    'showmediuminfo',
    'showvminfo',
    'signova',
    'snapshot',
    'startvm',
    'storageattach',
    'storagectl',
    'unattended',
    'unregistervm',
    'updatecheck',
    'usbdevsource',
    'usbfilter'
)

$script:VBoxManageSubCommands = @{
    bandwidthctl     = 'add list remove set'
    closemedium      = 'disk dvd floppy'
    cloud            = 'list instance image network'
    controlvm        = 'pause resume reset poweroff savestate acpipowerbutton acpisleepbutton reboot shutdown keyboardputscancode keyboardputstring keyboardputfile guestmemoryballoon usbattach usbdetach audioin audioout clipboard draganddrop vrde vrdeport vrdeproperty vrdevideochannelquality setvideomodehint setscreenlayout setscreenlayout screenshotpng recording setcredentials teleport plugcpu unplugcpu cpuexecutioncap vm-process-priority webcam addencpassword removeencpassword  removeallencpasswords autostart-enabledN autostart-delay'
    convertfromraw   = 'stdin'
    createmedium     = 'disk dvd floppy'
    debugvm          = 'dumpvmcore info injectnmi log logdest logflags osdetect osinfo osdmesg getregisters setregisters show stack statistics guestsample'
    dhcpserver       = 'add modify remove start restart stop findlease'
    encryptvm        = 'setencryption checkpassword addpassword removepassword'
    extpack          = 'install uninstall cleanup'
    guestcontrol     = 'run start copyfrom copyto mkdir rmdir rm mv mktemp mount fsinfo stat list closeprocess updatega wait'
    guestproperty    = 'get enumerate set unset wait'
    hostonlyif       = 'ipconfig create remove'
    hostonlynet      = 'add modify remove'
    internalcommands = 'loadmap loadsyms sethduuid sethdparentuuid dumphdinfo listpartitions createrawvmdk renamevmdk converttoraw converthd repairhd modinstall moduninstall debuglog passwordhash gueststats'
    list             = 'bridgedifs cloudnets cloudprofiles cloudproviders cpu-profiles dhcpservers dvds extpacks floppies groups hddbackends hdds hostcpuids hostdrives hostfloppies hostinfo hostonlyifs hostonlynets intnets natnets ostypes ossybtypes runningvms screenshotformats systemproperties usbfilters usbhost vms webcams'
    mediumio         = 'formatfat cat stream'
    mediumproperty   = 'disk dvd floppy'
    metrics          = 'collect disable enable list query setup'
    modifymedium     = 'disk dvd floppy'
    modifynvram      = 'inituefivarstore enrollmssignatures enrollorclpk enrollpk enrollmok secureboot listvars queryvar deletevar changevar'
    natnetwork       = 'add list modify remove start stop'
    sharedfolder     = 'add remove modify'
    showmediuminfo   = 'disk dvd floppy'
    snapshot         = 'take delete restore restorecurrent edit list showvminfo'
    unattended       = 'detect install'
    updatecheck      = 'perform list modify'
    usbdevsource     = 'add remove'
    usbfilter        = 'add modify remove'
}

$script:VBoxManageCommandsMachineNames = @(
    'clonevm',
    'controlvm',
    'debugvm',
    'encryptvm',
    'modifyvm',
    'movevm',
    'registervm',
    'showvminfo',
    'snapshot',
    'unregistervm',
    'modifynvram',
    'adoptstate',
    'discardstate',
    'storageattach',
    'storagectl',
    'bandwidthctl',
    'setextradata',
    'getextradata',
    'guestcontrol'
)

$script:VBoxManageCommonParams = @(
    '-q', '--nologo', '--settingspw', '--settingspwfile', '-V', '--version', '--dump-build-type'
)

$script:VBoxManageParams = @{
    # eg: vboxmanage list --long
    list          = 'long platform-arch sorted'
    showvminfo    = 'details machinereadable password-id password'
    registervm    = 'password'
    unregistervm  = 'delete delete-all'
    createvm      = 'name platform-architecture basefolder default groups ostype register uuid cipher password-id password'
    modifyvm      = 'name groups description os-type icon-file memory page-fusion vram acpi ioapic hardware-uui cpus cpu-hotplugs plug-cpu unplug-cpu cpu-execution-cap x86-pae x86-long-mode ibpb-on-vm-exit ibpb-on-vm-entry spec-ctrl l1d-flush-on-sched l1d-flush-on-vm-entry mds-clear-on-sched mds-clear-on-vm-entry cpu-profile x86-hpet hwvirtex triple-fault-reset apic x86-x2apic paravirt-provider paravirt-debug nested-paging large-pages x86-vtx-vpid x86-vtx-ux nested-hw-virt virt-vmsave-vmload accelerate-3d accelerate-2d-video chipset iommu tpm-type tpm-location firmware-logo-fade-in firmware-logo-fade-out firmware-logo-display-time  firmware-logo-image-path firmware-boot-menu firmware-apic firmware-system-time-offset firmware-pxe-debug  system-uuid-le bootX rtc-use-utc graphicscontroller snapshot-folder firmware guest-memory-balloon  default-frontend vm-procress-priority vm-execution-engine mouse keyboard audio-controller audo-codec audio-driver audio-enabled audio-in audio-out clipboard-mode clipboard-file drag-and-drop monitor-count usb-ehci usb-ohci usb-xhci usb-rename recording recording-screens recording-file recording-max-size recording-max-time recording-opts recording-video-fps recording-video-rate recording-video-res vrde vrde-property vrde-extpack vrde-port vrde-address vrde-auth-type vrde-auth-library vrde-multi-con vrde-reuse-con vrde-video-channel vrde-video-channel-quality teleporter teleporter-port teleporter-address teleporter-password teleporter-password-file cpuid-portability-level cpuid-set cpuid-remove cpuid-remove-all tracing-enabled tracing-config tracing-allow-vm-access usb-card-reader autostart-enabled autostart-delay guest-debug-provider guest-debug-io-provider guest-debug-address guest-debug-port pci-attach pci-detach testing-enabled testing-mmio testing-cfg-dwordidx'
    clonevm       = 'basefolder groups mode name options register snapshot uuid'
    movevm        = 'type folder'
    startvm       = 'putenv type password password-id'
    import        = 'dry-run options vsys ostype vmname settingsfile basefolder group memory cpus description eula unit ignore scsitype disk controller port cloud cloudprofile cloudinstanceid cloudbucket'
    export        = 'output legacy09 ovf09 ovf10 ovf20 manifest options vsys description eula eulafile product producturl vendor vendorurl version vmname opc10 cloud cloudprofile cloudshape clouddomain clouddisksize cloudbucket cloudocivcn cloudocisubnet cloudkeepobject cloudlaunchinstance cloudlaunchmode cloudpublicip'
    mediumio      = 'disk dvd floppy password-file'
    cloud         = 'provider profile'
    cloudprofile  = 'provider profile'
    signova       = 'certificate private-key private-key-password-file private-key-password digest-type pkcs7 no-pkcs7 intermediate-cert force verbose quiet dry-run'
    storageattach = 'storagectl bandwidthgroup comment device discard encodedlun forceunmount hotpluggable initiator intnet lun medium mtype nonrotational passthrough passwordfile password port server setparentuuid setuuid target tempeject tport type username'
    storagectl    = 'name add controller bootable hostiocache portcount remove rename'
    encryptmedium = 'cipher newpassword newpasswordid oldpassword'
}
$script:VBoxManageParamsValue = @{
    #eg: vboxmanage controlvm --audioin on
    controlvm = @{
        audioin                   = 'on off'
        audioout                  = 'on off'
        "clipboard mode"          = 'disabled hosttoguest guesttohost bidirectional'
        "clipboard filetransfers" = 'on off'
        draganddrop               = 'disabled hosttoguest guesttohost bidirectional'
        vrde                      = 'on off'
        recording                 = 'on off start stop attach screens filename videores videorate videofps maxtime maxfilesize opts'
        "vm-process-priority"     = 'default flat low normal high'
        webcam                    = 'attach detach list'
    }
    cloud     = @{
        list     = 'instances images vnicattachments'
        instance = 'info terminate start pause reset clone metriclist metricdata'
        image    = 'create info delete import export'
        network  = 'setup create update delete info'
    }
}

$script:VBoxManageSubcommandLongParams = @{
    # eg: vboxmanage snapshot take --description
    snapshot      = @{
        take = 'description live uniquename'
        edit = 'current description name'
        list = 'details machinereadable'
    }
    encryptvm     = @{
        setencryption = 'old-password new-password new-password-id cipher force'
        addpassword   = 'password password-id'
    }
    controlvm     = @{
        shutdown  = 'force'
        usbattach = 'capturefile'
        recording = @{ start = 'wait' }
    }
    mediumio      = @{
        cat       = 'hex offset size output'
        stream    = 'format variant output'
        formatfat = 'quick'
    }
    sharedfolder  = @{
        add    = 'name hostpath readonly transient automount auto-mount-point'
        remove = 'name transient'
        modify = 'name readonly automount auto-mount-point symlink-policy'
    }
    dhcpserver    = @{
        add       = 'network interface server-ip netmask lower-ip upper-ip enable disable global group vm mac-address'
        modify    = 'network interface server-ip lower-ip upper-ip netmask enable disable global group vm mac-address'
        remove    = 'network interface'
        start     = 'network interface'
        restart   = 'network interface'
        stop      = 'network interface'
        findlease = 'network interface mac-address'
    }
    debugvm       = @{
        dumpvmcore   = 'filename'
        log          = 'release debug'
        logdest      = 'release debug'
        logflags     = 'release debug'
        osdmesg      = 'lines'
        getregisters = 'cpu'
        setregisters = 'cpu'
        show         = 'human-readable sh-export sh-eval cmd-set'
        stack        = 'cpu'
        statistics   = 'reset descriptions pattern'
        guestsample  = 'filename sample-interval-us sample-time'
    }
    extpack       = @{
        install   = 'replace accept-license'
        uninstall = 'force'
    }
    unattended    = @{
        detect  = 'iso machine-readable'
        install = 'iso user user-password admin-password password-file full-user-name key install-additions no-install-additions additions-iso install-txs no-install-txs validation-kit-iso locale country time-zone hostname dry-run package-selection-adjustment auxiliary-base-path image-index script-template post-install-template post-install-command extra-install-kernel-parameters language start-vm'
    }
    cloud         = @{
        list         = @{
            instances       = 'state compartment-id'
            images          = 'state compartment-id'
            vnicattachments = 'state compartment-id'
        }
        instance     = @{
            create     = 'domain-name image-id boot-volume-id display-name shape subnet boot-disk-size publicip privateip public-ssh-key lauch-mode cloud-init-script-path'
            info       = 'id'
            terminate  = 'id'
            start      = 'id'
            pause      = 'id'
            reset      = 'id'
            clone      = 'id clone-name'
            metriclist = 'id'
            metricdata = 'id metric-name metric-points'
        }
        image        = @{
            create = 'display-name bucket-name object-name instance-id'
            info   = 'id'
            delete = 'id'
            import = 'id bucket-name object-name'
            export = 'id display-name bucket-name object-name'
        }
        network      = @{
            setup  = 'gateway-os-name gateway-os-version gateway-shape tunnel-network-name tunnel-network-range proxy compartment-id'
            create = 'name network-id enable disable'
            update = 'name network-id enable disable'
            delete = 'name'
            info   = 'name'
        }
        guestcontrol = @{
            list = 'all files processes sessions'
        }
    }
    cloudprofile  = @{
        add    = 'clouduser fingerprint keyfile passphrase tenancy compartment region'
        update = 'clouduser fingerprint keyfile passphrase tenancy compartment region'
    }
    modifynvram   = @{
        enrollpk   = 'platform-key owner-uuid'
        enrollmok  = 'mok owner-uuid'
        secureboot = 'enable disable'
        queryvars  = 'name filename'
        deletevar  = 'name owner-uuid'
        changevar  = 'name filename'
    }
    hostonlynet   = @{
        add    = 'name id netmask lower-ip upper-ip enable disable'
        modify = 'name id netmask lower-ip upper-ip enable disable'
        remove = 'name id'
    }
    updatecheck   = @{
        perform = 'machine-readable'
        list    = 'machine-readable'
        modify  = 'disable enable channel frequency'
    }
    bandwidthctl  = @{
        add  = 'limit type'
        list = 'machinereadable'
        set  = 'limit'
    }
    createmedium  = @{
        disk   = 'filename size sizebyte diffparent format variant property property-file'
        dvd    = 'filename size sizebyte diffparent format variant property property-file'
        floppy = 'filename size sizebyte diffparent format variant property property-file'
    }
    modifymedium  = @{
        disk   = 'autoreset compact description move property resize resizebyte setlocation type'
        dvd    = 'autoreset compact description move property resize resizebyte setlocation type'
        floppy = 'autoreset compact description move property resize resizebyte setlocation type'
    }
    clonemedium   = @{
        disk   = 'existing format variant'
        dvd    = 'existing format variant'
        floppy = 'existing format variant'
    }
    usbfilter     = @{
        add    = 'target name action active vendorid productid revision manufacturer product port remote serialnumber maskedinterfaces'
        modify = 'target name action active vendorid productid revision manufacturer product port remote serialnumber maskedinterfaces'
        remove = 'target'
    }
    guestproperty = @{
        get       = 'verbose'
        enumerate = 'no-timestamp no-flags relative old-format'
        wait      = 'timeout fail-on-timeout'
    }
    guestcontrol  = @{
        run          = 'arg0 domain dos2unix exe ignore-orphaned-processes no-wait-stderr wait-stderr no-wait-stdout wait-stdout passwordfile password profile putenv quiet timeout unix2dos unquoted username cwd verbose'
        start        = 'arg0 domain dos2unix exe ignore-orphaned-processes no-wait-stderr wait-stderr no-wait-stdout wait-stdout passwordfile password profile putenv quiet timeout unix2dos unquoted username cwd verbose'
        copyfrom     = 'dereference domain passwordfile password quiet no-replace recursive target-directory update username verbose'
        copyto       = 'dereference domain passwordfile password quiet no-replace recursive target-directory update username verbose'
        mkdir        = 'domain mode parents passwordfile password quiet username verbose'
        rmdir        = 'domain mode parents passwordfile password quiet username verbose'
        rm           = 'domain force passwordfile password quiet username verbose'
        mv           = 'domain passwordfile password quiet username verbose'
        mktemp       = 'directory domain mode passwordfile password quiet secure tmpdir username verbose'
        mount        = 'passwordfile password username verbose'
        fsinfo       = 'domain passwordfile password human-readable quiet total username verbose'
        stat         = 'domain passwordfile password quiet username verbose'
        list         = 'quiet verbose'
        closeprocess = 'session-id session-name quiet verbose'
        closesession = 'all session-id session-name quiet verbose'
        updatega     = 'quiet verbose source wait-start'
        watch        = 'quiet verbose'
    }
    metrics       = @{
        collect = 'detach list period samples'
        disable = 'list'
        enable  = 'list'
        setup   = 'list period samples'
    }
    natnetwork    = @{
        add    = 'disable enable netname network dhcp ipv6 loopback-4 loopback-6 port-forward-4 port-forward-6'
        modify = 'dhcp disable enable netname network ipv6 loopback-4 loopback-6 port-forward-4 port-forward-6'
        remove = 'netname'
        start  = 'netname'
        stop   = 'netname'
    }
    hostonlyif    = @{
        ipconfig = 'dhcp ip netmask ipv6 netmasklengthv6'
    }
    usbdevsource  = @{
        add = 'backend address'
    }
}

function script:VBoxManageVMs {
    [array]$list = &"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list vms
    if ($list -match '"(.+)"') {
        $names = $matches[1].Trim()
    }
    $names 
}

function script:VBoxManageUuids {
    [array]$list = &"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" list vms
    if ($list -match '{(.+)}') {
        $uuids = $matches[1].Trim()
    }
    $uuids
}

$script:VBoxManageCommandsWithParams = $VBoxManageParams.Keys -join '|'

function script:VBoxManageExpandCmd($filter) {
    $cmdList = @()
    $cmdList += $VBoxManageCommands
    $cmdList -like "$filter*" | Sort-Object
}

function script:VBoxManageExpandSubCmd($cmd, $subcmd, $filter) {
    $VBoxManageSubCommands[$cmd][$subcmd] -split ' ' | Where-Object { $_ -like "$filter*" } | Sort-Object
}

function script:VBoxManageExpandCmdParams($commands, $command, $filter) {
    $commands.$command -split ' ' | Where-Object { $_ -like "$filter*" }
}

function script:VBoxManageExpandParams($cmd, $filter) {
    $VBoxManageParams[$cmd] -split ' ' | \
    Where-Object { $_ -like "$filter*" } | \
    Sort-Object | \
    ForEach-Object { -join ("--", $_) }
}

function script:VBoxManageTabExpansion($lastBlock) {
    switch -regex ($lastBlock) {
        # VBoxManage <cmd>
        "^(?<cmd>\S*)$" {
            return VBoxManageExpandCmd $matches['cmd'] $true
        }

        # VBoxManage <cmd> --<param>
        "^(?<cmd>$VBoxManageCommandsWithParams).* --(?<param>\S*)$" {
            return VBoxManageExpandParams $matches['cmd'] $matches['param']
        }

        # VboxManage <cmd> <subcmd>
        "^(?<cmd>$($VBoxManageSubCommands.Keys -join '|'))\s+(?<op>\S*)$" {
            return VBoxManageExpandCmdParams $VBoxManageSubCommands $matches['cmd'] $matches['op']
        }
    }
}

Register-ArgumentCompleter -Native -CommandName VBoxManage -ScriptBlock {
    param ($wordToComplete, $commandAst, $cursorColumn)

    $cmdLine = [string]$commandAst
    $cmdLine = $cmdLine.Substring(0, [Math]::Min($cmdLine.Length, $cursorColumn))
    $argList = (($cmdLine -replace '^\S+\s*') + ' ' * ($cursorColumn - $cmdLine.Length)).TrimStart()

    VBoxManageTabExpansion $argList
}