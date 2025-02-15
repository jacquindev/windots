# bash completion for vctl                                 -*- shell-script -*-

__vctl_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__vctl_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__vctl_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__vctl_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__vctl_handle_go_custom_completion()
{
    __vctl_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly vctl allows to handle aliases
    args=("${words[@]:1}")
    requestComp="${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __vctl_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __vctl_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __vctl_debug "${FUNCNAME[0]}: calling ${requestComp}"
    # Use eval to handle any environment variables and such
    out=$(eval "${requestComp}" 2>/dev/null)

    # Extract the directive integer at the very end of the output following a colon (:)
    directive=${out##*:}
    # Remove the directive
    out=${out%:*}
    if [ "${directive}" = "${out}" ]; then
        # There is not directive specified
        directive=0
    fi
    __vctl_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __vctl_debug "${FUNCNAME[0]}: the completions are: ${out[*]}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __vctl_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __vctl_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __vctl_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out[*]}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __vctl_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subDir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out[0]}")
        if [ -n "$subdir" ]; then
            __vctl_debug "Listing directories in $subdir"
            __vctl_handle_subdirs_in_dir_flag "$subdir"
        else
            __vctl_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out[*]}" -- "$cur")
    fi
}

__vctl_handle_reply()
{
    __vctl_debug "${FUNCNAME[0]}"
    local comp
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            while IFS='' read -r comp; do
                COMPREPLY+=("$comp")
            done < <(compgen -W "${allflags[*]}" -- "$cur")
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __vctl_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __vctl_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions+=("${must_have_one_noun[@]}")
    elif [[ -n "${has_completion_function}" ]]; then
        # if a go completion function is provided, defer to that function
        __vctl_handle_go_custom_completion
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
    done < <(compgen -W "${completions[*]}" -- "$cur")

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${noun_aliases[*]}" -- "$cur")
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __vctl_custom_func >/dev/null; then
			# try command name qualified custom func
			__vctl_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__vctl_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__vctl_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__vctl_handle_flag()
{
    __vctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __vctl_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __vctl_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __vctl_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __vctl_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __vctl_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__vctl_handle_noun()
{
    __vctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __vctl_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __vctl_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__vctl_handle_command()
{
    __vctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_vctl_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __vctl_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__vctl_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __vctl_handle_reply
        return
    fi
    __vctl_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __vctl_handle_flag
    elif __vctl_contains_word "${words[c]}" "${commands[@]}"; then
        __vctl_handle_command
    elif [[ $c -eq 0 ]]; then
        __vctl_handle_command
    elif __vctl_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __vctl_handle_command
        else
            __vctl_handle_noun
        fi
    else
        __vctl_handle_noun
    fi
    __vctl_handle_word
}

_vctl_build()
{
    last_command="vctl_build"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--builder-mem=")
    two_word_flags+=("--builder-mem")
    local_nonpersistent_flags+=("--builder-mem")
    local_nonpersistent_flags+=("--builder-mem=")
    flags+=("--credential=")
    two_word_flags+=("--credential")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--credential")
    local_nonpersistent_flags+=("--credential=")
    local_nonpersistent_flags+=("-c")
    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--file")
    local_nonpersistent_flags+=("--file=")
    local_nonpersistent_flags+=("-f")
    flags+=("--kind-load")
    local_nonpersistent_flags+=("--kind-load")
    flags+=("--no-local-cache")
    local_nonpersistent_flags+=("--no-local-cache")
    flags+=("--tag=")
    two_word_flags+=("--tag")
    flags_with_completion+=("--tag")
    flags_completion+=("__vctl_handle_go_custom_completion")
    two_word_flags+=("-t")
    flags_with_completion+=("-t")
    flags_completion+=("__vctl_handle_go_custom_completion")
    local_nonpersistent_flags+=("--tag")
    local_nonpersistent_flags+=("--tag=")
    local_nonpersistent_flags+=("-t")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_completion()
{
    last_command="vctl_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("fish")
    must_have_one_noun+=("powershell")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_vctl_create()
{
    last_command="vctl_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--entrypoint=")
    two_word_flags+=("--entrypoint")
    local_nonpersistent_flags+=("--entrypoint")
    local_nonpersistent_flags+=("--entrypoint=")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env")
    local_nonpersistent_flags+=("--env=")
    local_nonpersistent_flags+=("-e")
    flags+=("--hostname=")
    two_word_flags+=("--hostname")
    local_nonpersistent_flags+=("--hostname")
    local_nonpersistent_flags+=("--hostname=")
    flags+=("--interactive")
    flags+=("-i")
    local_nonpersistent_flags+=("--interactive")
    local_nonpersistent_flags+=("-i")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    local_nonpersistent_flags+=("-n")
    flags+=("--privileged")
    flags+=("-r")
    local_nonpersistent_flags+=("--privileged")
    local_nonpersistent_flags+=("-r")
    flags+=("--publish=")
    two_word_flags+=("--publish")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--publish")
    local_nonpersistent_flags+=("--publish=")
    local_nonpersistent_flags+=("-p")
    flags+=("--tty")
    flags+=("-t")
    local_nonpersistent_flags+=("--tty")
    local_nonpersistent_flags+=("-t")
    flags+=("--volume=")
    two_word_flags+=("--volume")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--volume")
    local_nonpersistent_flags+=("--volume=")
    local_nonpersistent_flags+=("-v")
    flags+=("--workdir=")
    two_word_flags+=("--workdir")
    two_word_flags+=("-w")
    local_nonpersistent_flags+=("--workdir")
    local_nonpersistent_flags+=("--workdir=")
    local_nonpersistent_flags+=("-w")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_describe()
{
    last_command="vctl_describe"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_exec()
{
    last_command="vctl_exec"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--detach")
    flags+=("-d")
    local_nonpersistent_flags+=("--detach")
    local_nonpersistent_flags+=("-d")
    flags+=("--interactive")
    flags+=("-i")
    local_nonpersistent_flags+=("--interactive")
    local_nonpersistent_flags+=("-i")
    flags+=("--tty")
    flags+=("-t")
    local_nonpersistent_flags+=("--tty")
    local_nonpersistent_flags+=("-t")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_execvm()
{
    last_command="vctl_execvm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--container=")
    two_word_flags+=("--container")
    flags_with_completion+=("--container")
    flags_completion+=("__vctl_handle_go_custom_completion")
    two_word_flags+=("-c")
    flags_with_completion+=("-c")
    flags_completion+=("__vctl_handle_go_custom_completion")
    local_nonpersistent_flags+=("--container")
    local_nonpersistent_flags+=("--container=")
    local_nonpersistent_flags+=("-c")
    flags+=("--sh")
    flags+=("-s")
    local_nonpersistent_flags+=("--sh")
    local_nonpersistent_flags+=("-s")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_help()
{
    last_command="vctl_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_images()
{
    last_command="vctl_images"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--digests")
    flags+=("-d")
    local_nonpersistent_flags+=("--digests")
    local_nonpersistent_flags+=("-d")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_inspect()
{
    last_command="vctl_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_kind()
{
    last_command="vctl_kind"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_login()
{
    last_command="vctl_login"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--http")
    local_nonpersistent_flags+=("--http")
    flags+=("--password=")
    two_word_flags+=("--password")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    local_nonpersistent_flags+=("-p")
    flags+=("--password-stdin")
    local_nonpersistent_flags+=("--password-stdin")
    flags+=("--skip-ssl-check")
    local_nonpersistent_flags+=("--skip-ssl-check")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_logout()
{
    last_command="vctl_logout"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_ps()
{
    last_command="vctl_ps"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_pull()
{
    last_command="vctl_pull"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--http")
    local_nonpersistent_flags+=("--http")
    flags+=("--password=")
    two_word_flags+=("--password")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    local_nonpersistent_flags+=("-p")
    flags+=("--password-stdin")
    local_nonpersistent_flags+=("--password-stdin")
    flags+=("--skip-ssl-check")
    local_nonpersistent_flags+=("--skip-ssl-check")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_push()
{
    last_command="vctl_push"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--http")
    local_nonpersistent_flags+=("--http")
    flags+=("--password=")
    two_word_flags+=("--password")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    local_nonpersistent_flags+=("-p")
    flags+=("--password-stdin")
    local_nonpersistent_flags+=("--password-stdin")
    flags+=("--skip-ssl-check")
    local_nonpersistent_flags+=("--skip-ssl-check")
    flags+=("--username=")
    two_word_flags+=("--username")
    two_word_flags+=("-u")
    local_nonpersistent_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    local_nonpersistent_flags+=("-u")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_rm()
{
    last_command="vctl_rm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--volume")
    flags+=("-v")
    local_nonpersistent_flags+=("--volume")
    local_nonpersistent_flags+=("-v")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_rmi()
{
    last_command="vctl_rmi"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    local_nonpersistent_flags+=("-a")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_run()
{
    last_command="vctl_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cpus=")
    two_word_flags+=("--cpus")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--cpus")
    local_nonpersistent_flags+=("--cpus=")
    local_nonpersistent_flags+=("-c")
    flags+=("--detach")
    flags+=("-d")
    local_nonpersistent_flags+=("--detach")
    local_nonpersistent_flags+=("-d")
    flags+=("--entrypoint=")
    two_word_flags+=("--entrypoint")
    local_nonpersistent_flags+=("--entrypoint")
    local_nonpersistent_flags+=("--entrypoint=")
    flags+=("--env=")
    two_word_flags+=("--env")
    two_word_flags+=("-e")
    local_nonpersistent_flags+=("--env")
    local_nonpersistent_flags+=("--env=")
    local_nonpersistent_flags+=("-e")
    flags+=("--hostname=")
    two_word_flags+=("--hostname")
    local_nonpersistent_flags+=("--hostname")
    local_nonpersistent_flags+=("--hostname=")
    flags+=("--interactive")
    flags+=("-i")
    local_nonpersistent_flags+=("--interactive")
    local_nonpersistent_flags+=("-i")
    flags+=("--keepVM")
    local_nonpersistent_flags+=("--keepVM")
    flags+=("--label=")
    two_word_flags+=("--label")
    two_word_flags+=("-l")
    local_nonpersistent_flags+=("--label")
    local_nonpersistent_flags+=("--label=")
    local_nonpersistent_flags+=("-l")
    flags+=("--memory=")
    two_word_flags+=("--memory")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--memory")
    local_nonpersistent_flags+=("--memory=")
    local_nonpersistent_flags+=("-m")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    local_nonpersistent_flags+=("-n")
    flags+=("--privileged")
    flags+=("-r")
    local_nonpersistent_flags+=("--privileged")
    local_nonpersistent_flags+=("-r")
    flags+=("--publish=")
    two_word_flags+=("--publish")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--publish")
    local_nonpersistent_flags+=("--publish=")
    local_nonpersistent_flags+=("-p")
    flags+=("--rm")
    local_nonpersistent_flags+=("--rm")
    flags+=("--tty")
    flags+=("-t")
    local_nonpersistent_flags+=("--tty")
    local_nonpersistent_flags+=("-t")
    flags+=("--volume=")
    two_word_flags+=("--volume")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--volume")
    local_nonpersistent_flags+=("--volume=")
    local_nonpersistent_flags+=("-v")
    flags+=("--workdir=")
    two_word_flags+=("--workdir")
    two_word_flags+=("-w")
    local_nonpersistent_flags+=("--workdir")
    local_nonpersistent_flags+=("--workdir=")
    local_nonpersistent_flags+=("-w")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_start()
{
    last_command="vctl_start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cpus=")
    two_word_flags+=("--cpus")
    two_word_flags+=("-c")
    local_nonpersistent_flags+=("--cpus")
    local_nonpersistent_flags+=("--cpus=")
    local_nonpersistent_flags+=("-c")
    flags+=("--detach")
    flags+=("-d")
    local_nonpersistent_flags+=("--detach")
    local_nonpersistent_flags+=("-d")
    flags+=("--keepVM")
    local_nonpersistent_flags+=("--keepVM")
    flags+=("--memory=")
    two_word_flags+=("--memory")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--memory")
    local_nonpersistent_flags+=("--memory=")
    local_nonpersistent_flags+=("-m")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_stop()
{
    last_command="vctl_stop"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_system_config()
{
    last_command="vctl_system_config"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--k8s-cpus=")
    two_word_flags+=("--k8s-cpus")
    flags+=("--k8s-mem=")
    two_word_flags+=("--k8s-mem")
    flags+=("--vm-cpus=")
    two_word_flags+=("--vm-cpus")
    two_word_flags+=("-c")
    flags+=("--vm-mem=")
    two_word_flags+=("--vm-mem")
    two_word_flags+=("-m")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_system_info()
{
    last_command="vctl_system_info"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_system_start()
{
    last_command="vctl_system_start"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--log-level=")
    two_word_flags+=("--log-level")
    two_word_flags+=("-l")
    flags+=("--log-location=")
    two_word_flags+=("--log-location")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_system_stop()
{
    last_command="vctl_system_stop"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_system()
{
    last_command="vctl_system"

    command_aliases=()

    commands=()
    commands+=("config")
    commands+=("info")
    commands+=("start")
    commands+=("stop")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_tag()
{
    last_command="vctl_tag"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")

    must_have_one_flag=()
    must_have_one_noun=()
    has_completion_function=1
    noun_aliases=()
}

_vctl_version()
{
    last_command="vctl_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_volume_prune()
{
    last_command="vctl_volume_prune"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_volume()
{
    last_command="vctl_volume"

    command_aliases=()

    commands=()
    commands+=("prune")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_vctl_root_command()
{
    last_command="vctl"

    command_aliases=()

    commands=()
    commands+=("build")
    commands+=("completion")
    commands+=("create")
    commands+=("describe")
    commands+=("exec")
    commands+=("execvm")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("execv")
        aliashash["execv"]="execvm"
    fi
    commands+=("help")
    commands+=("images")
    commands+=("inspect")
    commands+=("kind")
    commands+=("login")
    commands+=("logout")
    commands+=("ps")
    commands+=("pull")
    commands+=("push")
    commands+=("rm")
    commands+=("rmi")
    commands+=("run")
    commands+=("start")
    commands+=("stop")
    commands+=("system")
    commands+=("tag")
    commands+=("version")
    commands+=("volume")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()


    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_vctl()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __vctl_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("vctl")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function
    local last_command
    local nouns=()

    __vctl_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_vctl vctl
else
    complete -o default -o nospace -F __start_vctl vctl
fi

# ex: ts=4 sw=4 et filetype=sh
