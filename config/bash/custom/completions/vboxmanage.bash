#!/usr/bin/env bash

# cSpell:disable

########################################################################################################################
# Source: - https://github.com/mug896/virtualbox-bash-completion

_vboxmanage_list() {
  local arg=$1 res i

  if [[ $arg == snapshot ]]; then
    res=$(vboxmanage snapshot "$VMNAME" list | sed -En 's/^\s*Name: (.*) \(UUID:.*/"\1"/p')
  else
    res=$(vboxmanage list vms | cut -d' ' -f1 | tr -d '"')
  fi

  WORDS=$res

  _vboxmanage_list=$WORDS
  IFS=$'\n' COMPREPLY=($WORDS)
}

_vboxmanage_quote() {
  local i
  if [[ $PREV == --snapshot || $HELP =~ "$PREV <snapshot-name>" ]]; then
    WORDS=$(vboxmanage snapshot "$VMNAME" list | sed -En 's/^\s*Name: (.*) \(UUID:.*/"\1"/p')
  else
    WORDS=$(vboxmanage list vms | sed -E 's/(.*").*/\1/')
  fi
  IFS=$'\n' COMPREPLY=($(compgen -W '$WORDS' -- \\\""$CUR"))
}

_vboxmanage_option() {
  local arg=$1 i

  if [[ $CMD2 == @(snapshot|encryptvm|controlvm|debugvm|modifynvram|bandwidthctl|guestcontrol) ]]; then
    if [[ -n $CMD3 ]]; then
      HELP=$(sed <<<"$HELP" -En "/vboxmanage $CMD2 [^ ]+ $CMD3/p")
    else
      HELP=""
    fi

  elif [[ $CMD2 == @(mediumio|cloudprofile) ]]; then
    if [[ -z $CMD3 ]]; then
      HELP=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' (.*) \w{3,}( .*|$)/\1/p')
    else
      HELP=$(sed <<<"$HELP" -En 's/.* '"$CMD3"' (.*)/\1/p')
    fi

  elif [[ $CMD2 == @(sharedfolder|dhcpserver|extpack|unattended|hostonlynet|updatecheck|usbfilter|guestproperty|metrics|natnetwork|hostonlyif|usbdevsource) ]]; then
    if [[ -n $CMD3 ]]; then
      HELP=$(sed <<<"$HELP" -En "/vboxmanage $CMD2 $CMD3/p")
    else
      HELP=""
    fi

  elif [[ $CMD2 == cloud ]]; then
    if [[ -z $CMD3 ]]; then
      HELP=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' (.*) \w{3,} \w{3,}( .*|$)/\1/p')
    elif [[ -n $CMD3 && -n $CMD4 ]]; then
      HELP=$(sed <<<"$HELP" -En "s/vboxmanage $CMD2.* $CMD3 $CMD4(.*)/\1/p")
    else
      HELP=""
    fi

  elif [[ $CMD2 == internalcommands ]]; then
    if [[ -n $CMD3 ]]; then
      HELP=$(sed <<<"$HELP" -En '/^ *'"$CMD3"' /,/^$/H; ${g; s/\n/ /g; p}')
    else
      HELP=""
    fi
  fi

  if [[ $arg != value ]]; then
    WORDS=$(grep <<<"$HELP" -Po -- '(?<![[:alnum:]])-[[:alnum:]-]*[[:alpha:]]')
    return
  fi

  if [[ $CMD2 == clonevm ]]; then
    case $PREV in
    --mode)
      WORDS=$'machine\nmachinechildren\nall'
      ;;
    --groups)
      WORDS=$(vboxmanage list groups)
      ;;
    esac

  elif [[ $CMD2 == modifyvm ]]; then
    case $PREV in
    --bridge-adapter[0-9])
      WORDS=$(vboxmanage list bridgedifs | sed -En 's/^Name:\s+//p')
      ;;
    --host-only-adapter[0-9])
      WORDS=$(vboxmanage list hostonlyifs | sed -En 's/^Name:\s+//p')
      ;;
    --intnet[0-9])
      WORDS=$(vboxmanage list intnets | sed -En 's/^Name:\s+//p')
      ;;
    --nat-network[0-9])
      WORDS=$(vboxmanage list natnets | sed -En 's/^Name:\s+//p')
      ;;
    --host-only-net[0-9])
      WORDS=$(vboxmanage list hostonlynets | sed -En 's/^Name:\s+//p')
      ;;
    --groups)
      WORDS=$(vboxmanage list groups)
      ;;
    --default-frontend)
      WORDS=$(vboxmanage help startvm | sed -En '/^\s*--type=/{ s///; s/\|//g; p; Q }')" default"
      ;;
    --cpu-profile)
      WORDS=$'host\nIntel 8086\nIntel 80286\nIntel 80386'
      ;;
    esac

  elif [[ $CMD2 == natnetwork && $PREV == --netname ]]; then
    WORDS=$(vboxmanage list natnets | sed -En 's/^Name:\s+//p')

  elif [[ $CMD2 == @(cloud|cloudprofile) ]]; then
    case $PREV in
    --provider)
      WORDS=$(vboxmanage list cloudproviders | sed -En 's/^Short Name:\s+//p')
      ;;
    --profile)
      WORDS=$(vboxmanage list cloudprofiles | sed -En 's/^Name:\s+//p')
      ;;
    esac
    if [[ $CMD2 == cloud && $CMD3 == list && $PREV == --state ]]; then
      case $CMD4 in
      instances) WORDS=$'running\npaused\nterminated' ;;
      images) WORDS=$'available\ndisabled\ndeleted' ;;
      esac
    fi

  elif [[ $CMD2 == dhcpserver ]]; then
    case $PREV in
    --interface)
      WORDS=$(vboxmanage list hostonlyifs | sed -En 's/^Name:\s+//p')
      ;;
    --network)
      WORDS=$(vboxmanage list dhcpservers | sed -En 's/^NetworkName:\s+//p')
      ;;
    esac

  elif [[ $CMD2 == storageattach && $PREV == --storagectl ]]; then
    WORDS=$(vboxmanage showvminfo "$VMNAME" --machinereadable | sed -En 's/storagecontrollername[0-9]=//p')
    IFS=$'\n' COMPREPLY=($(compgen -W '$WORDS' -- \\\""$CUR"))
    return
  fi

  if [[ -z $WORDS ]]; then
    local opt=${PREV/%[0-9]/N}
    WORDS=$(sed <<<"$HELP" -En 's/.*'"$opt"'[= ]\[?((\[?(([[:alnum:].:]+-?)*[[:alnum:].:]+)\]?[,|/])+\[?(([[:alnum:].:]+-?)*[[:alnum:].:]+)\]?)]?.*/\1/; tX; b; :X s/[^[:alnum:].:-]/\n/g; p')
  fi
}

_vboxmanage_words() {
  local RE='[[:alnum:]][[:alnum:]-]'

  if [[ $CMD2 == list ]]; then
    WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"'|--\w+//g; s/\[|]|\|/\n/g; p')

  elif [[ $CMD2 == setproperty ]]; then
    if [[ -z $CMD3 ]]; then
      WORDS=$(vboxmanage help setproperty | sed -En '/^Description$/,/^Examples$/{ //d; /^[ ]{,3}\w+$/p }')
    elif [[ $CMD3 == proxymode ]]; then
      WORDS=$'manual\nnoproxy\nsystem'
    elif [[ $CMD3 == hwvirtexclusive ]]; then
      WORDS=$'on\noff'
    fi

  elif [[ $CMD2 == @(snapshot|encryptvm|controlvm|debugvm|modifynvram|bandwidthctl|guestcontrol) ]]; then
    if [[ -z $CMD3 ]]; then
      WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' [^ ]+ ('"$RE"*')( .*|$)/\1/p')
    elif [[ $CMD2 == guestcontrol && $PREV == list ]]; then
      WORDS='all\nfiles\nprocesses\nsessions'
    elif [[ $CMD2 == controlvm ]]; then
      case $CMD3 in
      setlinkstate[0-9] | nictrace[0-9] | audioin | audioout | vrde | autostart-enabled[0-9])
        WORDS=$'on\noff'
        ;;
      nic[0-9])
        WORDS=$'null\nnat\nbridged\nintnet\nhostonly\ngeneric\nnatnetwork'
        ;;
      nicpromisc[0-9])
        WORDS=$'deny\nallow-vms\nallow-all'
        ;;
      natpf[0-9])
        WORDS=$'rulename\ntcp\nudp\nhost-IP\nhostport\nguest-IP\nguestport'
        ;;
      clipboard)
        if [[ $PREV == clipboard ]]; then
          WORDS=$'mode\nfiletransfers'
        elif [[ $PREV == mode ]]; then
          WORDS=$'disabled\nhosttoguest\nguesttohost\nbidirectional'
        elif [[ $PREV == filetransfers ]]; then
          WORDS=$'on\noff'
        fi
        ;;
      draganddrop)
        WORDS=$'disabled\nhosttoguest\nguesttohost\nbidirectional'
        ;;
      recording)
        WORDS=$'on\noff\nscreens\nfilename\nvideores\nvideorate\nvideofps
                    maxtime\nmaxfilesize'
        ;;
      webcam)
        WORDS=$'attach\ndetach\nlist'
        ;;
      vm-process-priority)
        WORDS=$'default\nflat\nlow\nnormal\nhigh'
        ;;
      changeuartmode[0-9])
        WORDS=$'disconnected\nserverpipe-name\nclientpipe-name\ntcpserverport
                    tcpclienthostname:port\nfilefilename\ndevice-name'
        ;;
      esac
    fi

  elif [[ -z $CMD3 && $CMD2 == @(mediumio|cloudprofile) ]]; then
    WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' .* ('"$RE"'{2,})( .*|$)/\1/p')

  elif [[ $CMD2 == @(sharedfolder|dhcpserver|extpack|unattended|hostonlynet|updatecheck|convertfromraw|usbfilter|guestproperty|metrics|natnetwork|hostonlyif|usbdevsource) ]]; then
    if [[ -z $CMD3 ]]; then
      WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' ('"$RE"'*)( .*|$)/\1/p')
    elif [[ $CMD2 == metrics ]]; then
      WORDS=$'\\"*\\"\nhost\nvmname\nmetrics-list'
    elif [[ $CMD2 == hostonlyif && $PREV == @(ipconfig|remove) ]]; then
      WORDS=$(vboxmanage list hostonlyifs | sed -En 's/^Name:\s+//p')
    fi

  elif [[ $CMD2 == cloud ]]; then
    if [[ -z $CMD3 ]]; then
      WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"'.* ('"$RE"'{2,}) '"$RE"'{2,}( .*|$)/\1/p')
    elif [[ -z $CMD4 ]]; then
      WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"'.* '"$CMD3"' ('"$RE"'{2,})( .*|$)/\1/p')
    fi

  elif [[ $CMD2 == @(showmediuminfo|createmedium|modifymedium|mediumproperty|closemedium) ]]; then
    if [[ $PREV == $CMD2 ]]; then
      WORDS=$'disk\ndvd\nfloppy'
    elif [[ -z $CMD3 && $CMD2 == mediumproperty ]]; then
      WORDS=$(sed <<<"$HELP" -En 's/'"vboxmanage $CMD2"' [^ ]+ ('"$RE"'*)( .*|$)/\1/p')
    fi

  elif [[ $CMD2 == clonemedium ]]; then
    [[ -n $CMD3 && -n $CMD4 && $PREV == $CMD4 ]] && WORDS=$'disk\ndvd\nfloppy'

  elif [[ $CMD2 == getextradata ]]; then
    WORDS=$'keyword\nenumerate'
  fi
}

_vboxmanage_set_cmds() {
  local i
  for ((i = 1; i < COMP_CWORD; i++)); do
    [[ ${COMP_WORDS[i]} == @(-q|--nologo) ]] && continue
    [[ ${COMP_WORDS[i]} == "@" ]] && {
      let i++
      continue
    }
    if [[ ${COMP_WORDS[i]} == @(--settingspw|--settingspwfile) ]]; then
      [[ ${COMP_WORDS[i + 1]} == "=" ]] && let i+=2 || let i++
      continue
    fi
    break
  done
  if ((i < COMP_CWORD)); then
    CMD2=${COMP_WORDS[i]}
    VMNAME=${COMP_WORDS[i + 1]#\"} VMNAME=${VMNAME%\"}
  fi
  [[ -z $CMD2 ]] && return
  case $CMD2 in
  sharedfolder | dhcpserver | extpack | unattended | hostonlynet | updatecheck | usbfilter | \
    setproperty | guestproperty | metrics | natnetwork | hostonlyif | usbdevsource | \
    convertfromraw | clonemedium | internalcommands)
    ((i + 1 < COMP_CWORD)) && CMD3=${COMP_WORDS[i + 1]}
    if [[ $CMD2 == clonemedium ]] && ((i + 2 < COMP_CWORD)); then
      CMD4=${COMP_WORDS[i + 2]}
    fi
    ;;
  snapshot | encryptvm | controlvm | debugvm | modifynvram | bandwidthctl | guestcontrol | \
    mediumproperty)
    ((i + 2 < COMP_CWORD)) && CMD3=${COMP_WORDS[i + 2]}
    ;;
  mediumio | cloud | cloudprofile)
    for ((++i; i < COMP_CWORD; i++)); do
      if [[ ${COMP_WORDS[i]} == --* ]]; then
        [[ ${COMP_WORDS[i + 1]} == "=" ]] && let i+=2 || let i++
        continue
      fi
      break
    done
    ((i < COMP_CWORD)) && CMD3=${COMP_WORDS[i]}
    if [[ $CMD2 == cloud ]] && ((i + 1 < COMP_CWORD)); then
      CMD4=${COMP_WORDS[i + 1]}
    fi
    ;;
  esac
}
_init_comp_wordbreaks() {
  if [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
    [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
    [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
  fi
  if ! [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
    PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
  fi
}
_vboxmanage() {
  # It is recommended that all completion functions start with _init_comp_wordbreaks,
  # regardless of whether you change the COMP_WORDBREAKS variable afterward.
  _init_comp_wordbreaks
  [[ $COMP_WORDBREAKS != *@* ]] && COMP_WORDBREAKS+="@"

  local CMD2 CMD3 CMD4 VMNAME
  local CUR=${COMP_WORDS[COMP_CWORD]}
  [[ ${COMP_LINE:COMP_POINT-1:1} = " " || $COMP_WORDBREAKS == *"$CUR"* ]] && CUR=""
  local PREV=${COMP_WORDS[COMP_CWORD - 1]}
  [[ $PREV == "=" ]] && PREV=${COMP_WORDS[COMP_CWORD - 2]}
  local IFS=$' \t\n' WORDS HELP
  _vboxmanage_set_cmds
  if [[ -n $CMD2 ]]; then
    if [[ $CMD2 == internalcommands ]]; then
      HELP=$(vboxmanage internalcommands)
    else
      HELP=$(vboxmanage "$CMD2" | sed -Ez 's/ *\n {5,}/ /g; s/^([^\n]*\n){1}\n//; s/\n\n+/\n/g; s/ \| /\|/g; s/= /=/g')
    fi
  fi

  if [[ $CUR == -* ]]; then
    if [[ -z $CMD2 ]]; then
      WORDS=$'-V\n--version\n--dump-build-type\n-q\n--nologo\n--settingspw=
--settingspwfile='
    else
      _vboxmanage_option
    fi

  elif [[ $CUR == +([0-9]) && -n $_vboxmanage_list ]]; then
    CUR=$((10#$CUR))
    COMPREPLY=$(gawk <<<"$_vboxmanage_list" $CUR' == $1+0 {sub(/^[0-9]+) +/,""); print $0; exit}')

  elif [[ ${COMP_WORDS[COMP_CWORD]} == "@" || $PREV == "@" ]]; then
    :

  elif [[ $PREV != @(--settingspw|--settingspwfile) && (-z $CMD2 || $CMD2 == help) ]]; then
    WORDS=$(vboxmanage | sed -En 's/^\s*VBoxManage (\w+).*/\1/p')
    WORDS+=$'\ninternalcommands\nhelp'

  elif [[ $CMD2 = internalcommands && -z $CMD3 ]]; then
    WORDS=$(grep <<<"$HELP" -Po '(?<=^  )([a-z]+)')

  elif [[ ${COMP_WORDS[COMP_CWORD]} == \"* &&
    $PREV != @(--storagectl|--cpu-profile) ]]; then
    _vboxmanage_quote

  elif [[ $PREV == @(--ostype|--os-type) ]]; then
    WORDS=$(vboxmanage list ostypes | sed -En 's/^ID:\s+//p')

  elif [[ -z $CUR ]] && [[ $HELP =~ "$PREV <"[^\>]*(vmname|machines?)[^\>]*">" ]]; then
    _vboxmanage_list vmname

  elif [[ -z $CUR ]] && [[ $PREV == --snapshot || $HELP =~ "$PREV <snapshot-name>" ]]; then
    _vboxmanage_list snapshot

  elif [[ $PREV == -* && $CMD2 != @(metrics|list) ]]; then
    _vboxmanage_option value

  else
    [[ $CMD2 != internalcommands ]] && _vboxmanage_words
  fi

  if ! declare -p COMPREPLY &>/dev/null; then
    WORDS=$(sed <<<"$WORDS" -E 's/^[[:blank:]]+|[[:blank:]]+$//g')
    if [[ $WORDS == *" "* ]]; then
      IFS=$'\n' COMPREPLY=($(compgen -P \' -S \' -W "$WORDS" -- "$CUR"))
    else
      IFS=$'\n' COMPREPLY=($(compgen -W "$WORDS" -- "$CUR"))
    fi
  fi
  [[ ${COMPREPLY: -1} == "=" ]] && compopt -o nospace
}

complete -F _vboxmanage VBoxManage.exe
complete -F _vboxmanage vboxmanage
