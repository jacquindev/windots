# bash completion for op                                   -*- shell-script -*-

__op_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__op_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__op_index_of_word()
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

__op_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__op_handle_go_custom_completion()
{
    __op_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly op allows handling aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="OP_ACTIVE_HELP=0 ${words[0]} __completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __op_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __op_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __op_debug "${FUNCNAME[0]}: calling ${requestComp}"
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
    __op_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __op_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __op_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __op_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __op_debug "${FUNCNAME[0]}: activating no file completion"
                compopt +o default
            fi
        fi
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local fullFilter filter filteringCmd
        # Do not use quotes around the $out variable or else newline
        # characters will be kept.
        for filter in ${out}; do
            fullFilter+="$filter|"
        done

        filteringCmd="_filedir $fullFilter"
        __op_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __op_debug "Listing directories in $subdir"
            __op_handle_subdirs_in_dir_flag "$subdir"
        else
            __op_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__op_handle_reply()
{
    __op_debug "${FUNCNAME[0]}"
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
                __op_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION:-}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi

            if [[ -z "${flag_parsing_disabled}" ]]; then
                # If flag parsing is enabled, we have completed the flags and can return.
                # If flag parsing is disabled, we may not know all (or any) of the flags, so we fallthrough
                # to possibly call handle_go_custom_completion.
                return 0;
            fi
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __op_index_of_word "${prev}" "${flags_with_completion[@]}"
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
        __op_handle_go_custom_completion
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
        if declare -F __op_custom_func >/dev/null; then
            # try command name qualified custom func
            __op_custom_func
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
__op_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__op_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__op_handle_flag()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __op_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __op_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __op_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __op_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __op_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__op_handle_noun()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __op_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __op_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__op_handle_command()
{
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_op_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __op_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__op_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __op_handle_reply
        return
    fi
    __op_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __op_handle_flag
    elif __op_contains_word "${words[c]}" "${commands[@]}"; then
        __op_handle_command
    elif [[ $c -eq 0 ]]; then
        __op_handle_command
    elif __op_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __op_handle_command
        else
            __op_handle_noun
        fi
    else
        __op_handle_noun
    fi
    __op_handle_word
}

_op_account_add()
{
    last_command="op_account_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--address=")
    two_word_flags+=("--address")
    local_nonpersistent_flags+=("--address")
    local_nonpersistent_flags+=("--address=")
    flags+=("--email=")
    two_word_flags+=("--email")
    local_nonpersistent_flags+=("--email")
    local_nonpersistent_flags+=("--email=")
    flags+=("--raw")
    local_nonpersistent_flags+=("--raw")
    flags+=("--shorthand=")
    two_word_flags+=("--shorthand")
    local_nonpersistent_flags+=("--shorthand")
    local_nonpersistent_flags+=("--shorthand=")
    flags+=("--signin")
    local_nonpersistent_flags+=("--signin")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_account_forget()
{
    last_command="op_account_forget"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_account_get()
{
    last_command="op_account_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_account_list()
{
    last_command="op_account_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_account()
{
    last_command="op_account"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("forget")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_completion()
{
    last_command="op_completion"

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
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_group_grant()
{
    last_command="op_connect_group_grant"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all-servers")
    local_nonpersistent_flags+=("--all-servers")
    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_group_revoke()
{
    last_command="op_connect_group_revoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all-servers")
    local_nonpersistent_flags+=("--all-servers")
    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_group()
{
    last_command="op_connect_group"

    command_aliases=()

    commands=()
    commands+=("grant")
    commands+=("revoke")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server_create()
{
    last_command="op_connect_server_create"

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
    flags+=("--vaults=")
    two_word_flags+=("--vaults")
    local_nonpersistent_flags+=("--vaults")
    local_nonpersistent_flags+=("--vaults=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server_delete()
{
    last_command="op_connect_server_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server_edit()
{
    last_command="op_connect_server_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server_get()
{
    last_command="op_connect_server_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server_list()
{
    last_command="op_connect_server_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_server()
{
    last_command="op_connect_server"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_token_create()
{
    last_command="op_connect_token_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--expires-in=")
    two_word_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in=")
    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--server=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_token_delete()
{
    last_command="op_connect_token_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_token_edit()
{
    last_command="op_connect_token_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_token_list()
{
    last_command="op_connect_token_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_token()
{
    last_command="op_connect_token"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_vault_grant()
{
    last_command="op_connect_vault_grant"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--server=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_vault_revoke()
{
    last_command="op_connect_vault_revoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--server=")
    two_word_flags+=("--server")
    local_nonpersistent_flags+=("--server")
    local_nonpersistent_flags+=("--server=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--server=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect_vault()
{
    last_command="op_connect_vault"

    command_aliases=()

    commands=()
    commands+=("grant")
    commands+=("revoke")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_connect()
{
    last_command="op_connect"

    command_aliases=()

    commands=()
    commands+=("group")
    commands+=("server")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("servers")
        aliashash["servers"]="server"
    fi
    commands+=("token")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("tokens")
        aliashash["tokens"]="token"
    fi
    commands+=("vault")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document_create()
{
    last_command="op_document_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-name=")
    two_word_flags+=("--file-name")
    local_nonpersistent_flags+=("--file-name")
    local_nonpersistent_flags+=("--file-name=")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document_delete()
{
    last_command="op_document_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--archive")
    local_nonpersistent_flags+=("--archive")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document_edit()
{
    last_command="op_document_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-name=")
    two_word_flags+=("--file-name")
    local_nonpersistent_flags+=("--file-name")
    local_nonpersistent_flags+=("--file-name=")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document_get()
{
    last_command="op_document_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-mode=")
    two_word_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode=")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--include-archive")
    local_nonpersistent_flags+=("--include-archive")
    flags+=("--out-file=")
    two_word_flags+=("--out-file")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--out-file")
    local_nonpersistent_flags+=("--out-file=")
    local_nonpersistent_flags+=("-o")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document_list()
{
    last_command="op_document_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--include-archive")
    local_nonpersistent_flags+=("--include-archive")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_document()
{
    last_command="op_document"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_events-api_create()
{
    last_command="op_events-api_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--expires-in=")
    two_word_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in=")
    flags+=("--features=")
    two_word_flags+=("--features")
    local_nonpersistent_flags+=("--features")
    local_nonpersistent_flags+=("--features=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_events-api()
{
    last_command="op_events-api"

    command_aliases=()

    commands=()
    commands+=("create")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_create()
{
    last_command="op_group_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_delete()
{
    last_command="op_group_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_edit()
{
    last_command="op_group_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_get()
{
    last_command="op_group_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_list()
{
    last_command="op_group_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_user_grant()
{
    last_command="op_group_user_grant"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--role=")
    two_word_flags+=("--role")
    local_nonpersistent_flags+=("--role")
    local_nonpersistent_flags+=("--role=")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_flag+=("--user=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_user_list()
{
    last_command="op_group_user_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_user_revoke()
{
    last_command="op_group_user_revoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_flag+=("--user=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_group_user()
{
    last_command="op_group_user"

    command_aliases=()

    commands=()
    commands+=("grant")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("revoke")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_group()
{
    last_command="op_group"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("user")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("users")
        aliashash["users"]="user"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_help()
{
    last_command="op_help"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_inject()
{
    last_command="op_inject"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-mode=")
    two_word_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode=")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--in-file=")
    two_word_flags+=("--in-file")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--in-file")
    local_nonpersistent_flags+=("--in-file=")
    local_nonpersistent_flags+=("-i")
    flags+=("--out-file=")
    two_word_flags+=("--out-file")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--out-file")
    local_nonpersistent_flags+=("--out-file=")
    local_nonpersistent_flags+=("-o")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_create()
{
    last_command="op_item_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--category=")
    two_word_flags+=("--category")
    local_nonpersistent_flags+=("--category")
    local_nonpersistent_flags+=("--category=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--favorite")
    local_nonpersistent_flags+=("--favorite")
    flags+=("--generate-password")
    local_nonpersistent_flags+=("--generate-password")
    flags+=("--reveal")
    local_nonpersistent_flags+=("--reveal")
    flags+=("--ssh-generate-key=")
    two_word_flags+=("--ssh-generate-key")
    local_nonpersistent_flags+=("--ssh-generate-key")
    local_nonpersistent_flags+=("--ssh-generate-key=")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_delete()
{
    last_command="op_item_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--archive")
    local_nonpersistent_flags+=("--archive")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_edit()
{
    last_command="op_item_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--favorite")
    local_nonpersistent_flags+=("--favorite")
    flags+=("--generate-password")
    local_nonpersistent_flags+=("--generate-password")
    flags+=("--reveal")
    local_nonpersistent_flags+=("--reveal")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--title=")
    two_word_flags+=("--title")
    local_nonpersistent_flags+=("--title")
    local_nonpersistent_flags+=("--title=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_get()
{
    last_command="op_item_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--fields=")
    two_word_flags+=("--fields")
    local_nonpersistent_flags+=("--fields")
    local_nonpersistent_flags+=("--fields=")
    flags+=("--include-archive")
    local_nonpersistent_flags+=("--include-archive")
    flags+=("--otp")
    local_nonpersistent_flags+=("--otp")
    flags+=("--reveal")
    local_nonpersistent_flags+=("--reveal")
    flags+=("--share-link")
    local_nonpersistent_flags+=("--share-link")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_list()
{
    last_command="op_item_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--categories=")
    two_word_flags+=("--categories")
    local_nonpersistent_flags+=("--categories")
    local_nonpersistent_flags+=("--categories=")
    flags+=("--favorite")
    local_nonpersistent_flags+=("--favorite")
    flags+=("--include-archive")
    local_nonpersistent_flags+=("--include-archive")
    flags+=("--long")
    local_nonpersistent_flags+=("--long")
    flags+=("--tags=")
    two_word_flags+=("--tags")
    local_nonpersistent_flags+=("--tags")
    local_nonpersistent_flags+=("--tags=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_move()
{
    last_command="op_item_move"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--current-vault=")
    two_word_flags+=("--current-vault")
    local_nonpersistent_flags+=("--current-vault")
    local_nonpersistent_flags+=("--current-vault=")
    flags+=("--destination-vault=")
    two_word_flags+=("--destination-vault")
    local_nonpersistent_flags+=("--destination-vault")
    local_nonpersistent_flags+=("--destination-vault=")
    flags+=("--reveal")
    local_nonpersistent_flags+=("--reveal")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--destination-vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_share()
{
    last_command="op_item_share"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--emails=")
    two_word_flags+=("--emails")
    local_nonpersistent_flags+=("--emails")
    local_nonpersistent_flags+=("--emails=")
    flags+=("--expires-in=")
    two_word_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--view-once")
    local_nonpersistent_flags+=("--view-once")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_template_get()
{
    last_command="op_item_template_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-mode=")
    two_word_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode=")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--out-file=")
    two_word_flags+=("--out-file")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--out-file")
    local_nonpersistent_flags+=("--out-file=")
    local_nonpersistent_flags+=("-o")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_template_list()
{
    last_command="op_item_template_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item_template()
{
    last_command="op_item_template"

    command_aliases=()

    commands=()
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_item()
{
    last_command="op_item"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("move")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("mv")
        aliashash["mv"]="move"
    fi
    commands+=("share")
    commands+=("template")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("templates")
        aliashash["templates"]="template"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_clear()
{
    last_command="op_plugin_clear"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_credential_import()
{
    last_command="op_plugin_credential_import"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_credential()
{
    last_command="op_plugin_credential"

    command_aliases=()

    commands=()
    commands+=("import")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_init()
{
    last_command="op_plugin_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_inspect()
{
    last_command="op_plugin_inspect"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_list()
{
    last_command="op_plugin_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin_run()
{
    last_command="op_plugin_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_plugin()
{
    last_command="op_plugin"

    command_aliases=()

    commands=()
    commands+=("clear")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("reset")
        aliashash["reset"]="clear"
    fi
    commands+=("credential")
    commands+=("init")
    commands+=("inspect")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("info")
        aliashash["info"]="inspect"
    fi
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("run")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_read()
{
    last_command="op_read"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file-mode=")
    two_word_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode")
    local_nonpersistent_flags+=("--file-mode=")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    local_nonpersistent_flags+=("-f")
    flags+=("--no-newline")
    flags+=("-n")
    local_nonpersistent_flags+=("--no-newline")
    local_nonpersistent_flags+=("-n")
    flags+=("--out-file=")
    two_word_flags+=("--out-file")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--out-file")
    local_nonpersistent_flags+=("--out-file=")
    local_nonpersistent_flags+=("-o")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_run()
{
    last_command="op_run"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--env-file=")
    two_word_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file")
    local_nonpersistent_flags+=("--env-file=")
    flags+=("--no-masking")
    local_nonpersistent_flags+=("--no-masking")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_service-account_create()
{
    last_command="op_service-account_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--can-create-vaults")
    local_nonpersistent_flags+=("--can-create-vaults")
    flags+=("--expires-in=")
    two_word_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in")
    local_nonpersistent_flags+=("--expires-in=")
    flags+=("--raw")
    local_nonpersistent_flags+=("--raw")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_service-account_ratelimit()
{
    last_command="op_service-account_ratelimit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_service-account()
{
    last_command="op_service-account"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("ratelimit")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ratelimits")
        aliashash["ratelimits"]="ratelimit"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_signin()
{
    last_command="op_signin"

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
    flags+=("--raw")
    local_nonpersistent_flags+=("--raw")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_signout()
{
    last_command="op_signout"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--forget")
    local_nonpersistent_flags+=("--forget")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_update()
{
    last_command="op_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--channel=")
    two_word_flags+=("--channel")
    local_nonpersistent_flags+=("--channel")
    local_nonpersistent_flags+=("--channel=")
    flags+=("--directory=")
    two_word_flags+=("--directory")
    local_nonpersistent_flags+=("--directory")
    local_nonpersistent_flags+=("--directory=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_confirm()
{
    last_command="op_user_confirm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_delete()
{
    last_command="op_user_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_edit()
{
    last_command="op_user_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--travel-mode=")
    two_word_flags+=("--travel-mode")
    local_nonpersistent_flags+=("--travel-mode")
    local_nonpersistent_flags+=("--travel-mode=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_get()
{
    last_command="op_user_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--fingerprint")
    local_nonpersistent_flags+=("--fingerprint")
    flags+=("--me")
    local_nonpersistent_flags+=("--me")
    flags+=("--public-key")
    local_nonpersistent_flags+=("--public-key")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_list()
{
    last_command="op_user_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_provision()
{
    last_command="op_user_provision"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--email=")
    two_word_flags+=("--email")
    local_nonpersistent_flags+=("--email")
    local_nonpersistent_flags+=("--email=")
    flags+=("--language=")
    two_word_flags+=("--language")
    local_nonpersistent_flags+=("--language")
    local_nonpersistent_flags+=("--language=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--email=")
    must_have_one_flag+=("--name=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_reactivate()
{
    last_command="op_user_reactivate"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user_suspend()
{
    last_command="op_user_suspend"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--deauthorize-devices-after=")
    two_word_flags+=("--deauthorize-devices-after")
    local_nonpersistent_flags+=("--deauthorize-devices-after")
    local_nonpersistent_flags+=("--deauthorize-devices-after=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_user()
{
    last_command="op_user"

    command_aliases=()

    commands=()
    commands+=("confirm")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("provision")
    commands+=("reactivate")
    commands+=("suspend")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_create()
{
    last_command="op_vault_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--allow-admins-to-manage=")
    two_word_flags+=("--allow-admins-to-manage")
    local_nonpersistent_flags+=("--allow-admins-to-manage")
    local_nonpersistent_flags+=("--allow-admins-to-manage=")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--icon=")
    two_word_flags+=("--icon")
    local_nonpersistent_flags+=("--icon")
    local_nonpersistent_flags+=("--icon=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_delete()
{
    last_command="op_vault_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_edit()
{
    last_command="op_vault_edit"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--icon=")
    two_word_flags+=("--icon")
    local_nonpersistent_flags+=("--icon")
    local_nonpersistent_flags+=("--icon=")
    flags+=("--name=")
    two_word_flags+=("--name")
    local_nonpersistent_flags+=("--name")
    local_nonpersistent_flags+=("--name=")
    flags+=("--travel-mode=")
    two_word_flags+=("--travel-mode")
    local_nonpersistent_flags+=("--travel-mode")
    local_nonpersistent_flags+=("--travel-mode=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_get()
{
    last_command="op_vault_get"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_group_grant()
{
    last_command="op_vault_group_grant"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--no-input")
    local_nonpersistent_flags+=("--no-input")
    flags+=("--permissions=")
    two_word_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_flag+=("--permissions=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_group_list()
{
    last_command="op_vault_group_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_group_revoke()
{
    last_command="op_vault_group_revoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--no-input")
    local_nonpersistent_flags+=("--no-input")
    flags+=("--permissions=")
    two_word_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--group=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_group()
{
    last_command="op_vault_group"

    command_aliases=()

    commands=()
    commands+=("grant")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("revoke")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_list()
{
    last_command="op_vault_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--group=")
    two_word_flags+=("--group")
    local_nonpersistent_flags+=("--group")
    local_nonpersistent_flags+=("--group=")
    flags+=("--permission=")
    two_word_flags+=("--permission")
    local_nonpersistent_flags+=("--permission")
    local_nonpersistent_flags+=("--permission=")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_user_grant()
{
    last_command="op_vault_user_grant"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--no-input")
    local_nonpersistent_flags+=("--no-input")
    flags+=("--permissions=")
    two_word_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions=")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--permissions=")
    must_have_one_flag+=("--user=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_user_list()
{
    last_command="op_vault_user_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_user_revoke()
{
    last_command="op_vault_user_revoke"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--no-input")
    local_nonpersistent_flags+=("--no-input")
    flags+=("--permissions=")
    two_word_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions")
    local_nonpersistent_flags+=("--permissions=")
    flags+=("--user=")
    two_word_flags+=("--user")
    local_nonpersistent_flags+=("--user")
    local_nonpersistent_flags+=("--user=")
    flags+=("--vault=")
    two_word_flags+=("--vault")
    local_nonpersistent_flags+=("--vault")
    local_nonpersistent_flags+=("--vault=")
    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_flag+=("--user=")
    must_have_one_flag+=("--vault=")
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault_user()
{
    last_command="op_vault_user"

    command_aliases=()

    commands=()
    commands+=("grant")
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("revoke")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_vault()
{
    last_command="op_vault"

    command_aliases=()

    commands=()
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("remove")
        aliashash["remove"]="delete"
        command_aliases+=("rm")
        aliashash["rm"]="delete"
    fi
    commands+=("edit")
    commands+=("get")
    commands+=("group")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("groups")
        aliashash["groups"]="group"
    fi
    commands+=("list")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("user")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("users")
        aliashash["users"]="user"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_whoami()
{
    last_command="op_whoami"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_op_root_command()
{
    last_command="op"

    command_aliases=()

    commands=()
    commands+=("account")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("accounts")
        aliashash["accounts"]="account"
    fi
    commands+=("completion")
    commands+=("connect")
    commands+=("document")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("documents")
        aliashash["documents"]="document"
    fi
    commands+=("events-api")
    commands+=("group")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("groups")
        aliashash["groups"]="group"
    fi
    commands+=("help")
    commands+=("inject")
    commands+=("item")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("items")
        aliashash["items"]="item"
    fi
    commands+=("plugin")
    commands+=("read")
    commands+=("run")
    commands+=("service-account")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("sa")
        aliashash["sa"]="service-account"
    fi
    commands+=("signin")
    commands+=("signout")
    commands+=("update")
    commands+=("user")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("users")
        aliashash["users"]="user"
    fi
    commands+=("vault")
    if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
        command_aliases+=("vaults")
        aliashash["vaults"]="vault"
    fi
    commands+=("whoami")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--account=")
    two_word_flags+=("--account")
    flags+=("--cache")
    flags+=("--config=")
    two_word_flags+=("--config")
    flags+=("--debug")
    flags+=("--encoding=")
    two_word_flags+=("--encoding")
    flags+=("--format=")
    two_word_flags+=("--format")
    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    local_nonpersistent_flags+=("-h")
    flags+=("--iso-timestamps")
    flags+=("--no-color")
    flags+=("--session=")
    two_word_flags+=("--session")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_op()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __op_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("op")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __op_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_op op
else
    complete -o default -o nospace -F __start_op op
fi

# ex: ts=4 sw=4 et filetype=sh
