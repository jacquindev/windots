# bash completion for gum.exe                              -*- shell-script -*-

__gum.exe_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__gum.exe_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__gum.exe_index_of_word()
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

__gum.exe_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__gum.exe_handle_go_custom_completion()
{
    __gum.exe_debug "${FUNCNAME[0]}: cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}"

    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16

    local out requestComp lastParam lastChar comp directive args

    # Prepare the command to request completions for the program.
    # Calling ${words[0]} instead of directly gum.exe allows to handle aliases
    args=("${words[@]:1}")
    # Disable ActiveHelp which is not supported for bash completion v1
    requestComp="GUM.EXE_ACTIVE_HELP=0 ${words[0]} completion completeNoDesc ${args[*]}"

    lastParam=${words[$((${#words[@]}-1))]}
    lastChar=${lastParam:$((${#lastParam}-1)):1}
    __gum.exe_debug "${FUNCNAME[0]}: lastParam ${lastParam}, lastChar ${lastChar}"

    if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go method.
        __gum.exe_debug "${FUNCNAME[0]}: Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __gum.exe_debug "${FUNCNAME[0]}: calling ${requestComp}"
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
    __gum.exe_debug "${FUNCNAME[0]}: the completion directive is: ${directive}"
    __gum.exe_debug "${FUNCNAME[0]}: the completions are: ${out}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        # Error code.  No completion.
        __gum.exe_debug "${FUNCNAME[0]}: received error from custom completion go code"
        return
    else
        if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __gum.exe_debug "${FUNCNAME[0]}: activating no space"
                compopt -o nospace
            fi
        fi
        if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
            if [[ $(type -t compopt) = "builtin" ]]; then
                __gum.exe_debug "${FUNCNAME[0]}: activating no file completion"
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
        __gum.exe_debug "File filtering command: $filteringCmd"
        $filteringCmd
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        # Use printf to strip any trailing newline
        subdir=$(printf "%s" "${out}")
        if [ -n "$subdir" ]; then
            __gum.exe_debug "Listing directories in $subdir"
            __gum.exe_handle_subdirs_in_dir_flag "$subdir"
        else
            __gum.exe_debug "Listing directories in ."
            _filedir -d
        fi
    else
        while IFS='' read -r comp; do
            COMPREPLY+=("$comp")
        done < <(compgen -W "${out}" -- "$cur")
    fi
}

__gum.exe_handle_reply()
{
    __gum.exe_debug "${FUNCNAME[0]}"
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
                __gum.exe_index_of_word "${flag}" "${flags_with_completion[@]}"
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
    __gum.exe_index_of_word "${prev}" "${flags_with_completion[@]}"
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
        __gum.exe_handle_go_custom_completion
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
        if declare -F __gum.exe_custom_func >/dev/null; then
            # try command name qualified custom func
            __gum.exe_custom_func
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
__gum.exe_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__gum.exe_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
}

__gum.exe_handle_flag()
{
    __gum.exe_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue=""
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __gum.exe_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __gum.exe_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __gum.exe_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
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
    if [[ ${words[c]} != *"="* ]] && __gum.exe_contains_word "${words[c]}" "${two_word_flags[@]}"; then
        __gum.exe_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__gum.exe_handle_noun()
{
    __gum.exe_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __gum.exe_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __gum.exe_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__gum.exe_handle_command()
{
    __gum.exe_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_gum.exe_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __gum.exe_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__gum.exe_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __gum.exe_handle_reply
        return
    fi
    __gum.exe_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __gum.exe_handle_flag
    elif __gum.exe_contains_word "${words[c]}" "${commands[@]}"; then
        __gum.exe_handle_command
    elif [[ $c -eq 0 ]]; then
        __gum.exe_handle_command
    elif __gum.exe_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION:-}" || "${BASH_VERSINFO[0]:-}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __gum.exe_handle_command
        else
            __gum.exe_handle_noun
        fi
    else
        __gum.exe_handle_noun
    fi
    __gum.exe_handle_word
}

_gum.exe_choose()
{
    last_command="gum.exe_choose"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--limit")
    flags+=("--no-limit")
    flags+=("--ordered")
    flags+=("--height")
    flags+=("--cursor=")
    two_word_flags+=("--cursor")
    flags+=("--show-help")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--cursor-prefix=")
    two_word_flags+=("--cursor-prefix")
    flags+=("--selected-prefix=")
    two_word_flags+=("--selected-prefix")
    flags+=("--unselected-prefix=")
    two_word_flags+=("--unselected-prefix")
    flags+=("--selected")
    flags+=("--select-if-one")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--item.foreground=")
    two_word_flags+=("--item.foreground")
    flags+=("--item.background=")
    two_word_flags+=("--item.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_confirm()
{
    last_command="gum.exe_confirm"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--default")
    flags+=("--affirmative=")
    two_word_flags+=("--affirmative")
    flags+=("--negative=")
    two_word_flags+=("--negative")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--unselected.foreground=")
    two_word_flags+=("--unselected.foreground")
    flags+=("--unselected.background=")
    two_word_flags+=("--unselected.background")
    flags+=("--show-help")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_file()
{
    last_command="gum.exe_file"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cursor=")
    two_word_flags+=("--cursor")
    two_word_flags+=("-c")
    flags+=("--all")
    flags+=("-a")
    flags+=("--file")
    flags+=("--directory")
    flags+=("--show-help")
    flags+=("--height")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--symlink.foreground=")
    two_word_flags+=("--symlink.foreground")
    flags+=("--symlink.background=")
    two_word_flags+=("--symlink.background")
    flags+=("--directory.foreground=")
    two_word_flags+=("--directory.foreground")
    flags+=("--directory.background=")
    two_word_flags+=("--directory.background")
    flags+=("--file.foreground=")
    two_word_flags+=("--file.foreground")
    flags+=("--file.background=")
    two_word_flags+=("--file.background")
    flags+=("--permissions.foreground=")
    two_word_flags+=("--permissions.foreground")
    flags+=("--permissions.background=")
    two_word_flags+=("--permissions.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")
    flags+=("--file-size.foreground=")
    two_word_flags+=("--file-size.foreground")
    flags+=("--file-size.background=")
    two_word_flags+=("--file-size.background")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_filter()
{
    last_command="gum.exe_filter"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--indicator=")
    two_word_flags+=("--indicator")
    flags+=("--indicator.foreground=")
    two_word_flags+=("--indicator.foreground")
    flags+=("--indicator.background=")
    two_word_flags+=("--indicator.background")
    flags+=("--limit")
    flags+=("--no-limit")
    flags+=("--select-if-one")
    flags+=("--strict")
    flags+=("--selected-prefix=")
    two_word_flags+=("--selected-prefix")
    flags+=("--selected-indicator.foreground=")
    two_word_flags+=("--selected-indicator.foreground")
    flags+=("--selected-indicator.background=")
    two_word_flags+=("--selected-indicator.background")
    flags+=("--unselected-prefix=")
    two_word_flags+=("--unselected-prefix")
    flags+=("--unselected-prefix.foreground=")
    two_word_flags+=("--unselected-prefix.foreground")
    flags+=("--unselected-prefix.background=")
    two_word_flags+=("--unselected-prefix.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--text.foreground=")
    two_word_flags+=("--text.foreground")
    flags+=("--text.background=")
    two_word_flags+=("--text.background")
    flags+=("--cursor-text.foreground=")
    two_word_flags+=("--cursor-text.foreground")
    flags+=("--cursor-text.background=")
    two_word_flags+=("--cursor-text.background")
    flags+=("--match.foreground=")
    two_word_flags+=("--match.foreground")
    flags+=("--match.background=")
    two_word_flags+=("--match.background")
    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--placeholder.foreground=")
    two_word_flags+=("--placeholder.foreground")
    flags+=("--placeholder.background=")
    two_word_flags+=("--placeholder.background")
    flags+=("--width")
    flags+=("--height")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--reverse")
    flags+=("--fuzzy")
    flags+=("--sort")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_format()
{
    last_command="gum.exe_format"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--theme=")
    two_word_flags+=("--theme")
    flags+=("--language=")
    two_word_flags+=("--language")
    two_word_flags+=("-l")
    flags+=("--type=")
    two_word_flags+=("--type")
    two_word_flags+=("-t")

    noun_aliases=()
}

_gum.exe_input()
{
    last_command="gum.exe_input"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--placeholder.foreground=")
    two_word_flags+=("--placeholder.foreground")
    flags+=("--placeholder.background=")
    two_word_flags+=("--placeholder.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--cursor.mode=")
    two_word_flags+=("--cursor.mode")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--char-limit")
    flags+=("--width")
    flags+=("--password")
    flags+=("--show-help")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_join()
{
    last_command="gum.exe_join"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--align=")
    two_word_flags+=("--align")
    flags+=("--horizontal")
    flags+=("--vertical")

    noun_aliases=()
}

_gum.exe_pager()
{
    last_command="gum.exe_pager"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--foreground=")
    two_word_flags+=("--foreground")
    flags+=("--background=")
    two_word_flags+=("--background")
    flags+=("--help.foreground=")
    two_word_flags+=("--help.foreground")
    flags+=("--help.background=")
    two_word_flags+=("--help.background")
    flags+=("--show-line-numbers")
    flags+=("--line-number.foreground=")
    two_word_flags+=("--line-number.foreground")
    flags+=("--line-number.background=")
    two_word_flags+=("--line-number.background")
    flags+=("--soft-wrap")
    flags+=("--match.foreground=")
    two_word_flags+=("--match.foreground")
    flags+=("--match.background=")
    two_word_flags+=("--match.background")
    flags+=("--match-highlight.foreground=")
    two_word_flags+=("--match-highlight.foreground")
    flags+=("--match-highlight.background=")
    two_word_flags+=("--match-highlight.background")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_spin()
{
    last_command="gum.exe_spin"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--show-output")
    flags+=("--show-error")
    flags+=("--spinner=")
    two_word_flags+=("--spinner")
    two_word_flags+=("-s")
    flags+=("--spinner.foreground=")
    two_word_flags+=("--spinner.foreground")
    flags+=("--spinner.background=")
    two_word_flags+=("--spinner.background")
    flags+=("--title=")
    two_word_flags+=("--title")
    flags+=("--title.foreground=")
    two_word_flags+=("--title.foreground")
    flags+=("--title.background=")
    two_word_flags+=("--title.background")
    flags+=("--align=")
    two_word_flags+=("--align")
    two_word_flags+=("-a")
    flags+=("--timeout")

    noun_aliases=()
}

_gum.exe_style()
{
    last_command="gum.exe_style"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--foreground=")
    two_word_flags+=("--foreground")
    flags+=("--background=")
    two_word_flags+=("--background")
    flags+=("--border=")
    two_word_flags+=("--border")
    flags+=("--border-background=")
    two_word_flags+=("--border-background")
    flags+=("--border-foreground=")
    two_word_flags+=("--border-foreground")
    flags+=("--align=")
    two_word_flags+=("--align")
    flags+=("--height")
    flags+=("--width")
    flags+=("--margin=")
    two_word_flags+=("--margin")
    flags+=("--padding=")
    two_word_flags+=("--padding")
    flags+=("--bold")
    flags+=("--faint")
    flags+=("--italic")
    flags+=("--strikethrough")
    flags+=("--underline")

    noun_aliases=()
}

_gum.exe_table()
{
    last_command="gum.exe_table"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--separator=")
    two_word_flags+=("--separator")
    two_word_flags+=("-s")
    flags+=("--columns")
    flags+=("-c")
    flags+=("--widths")
    flags+=("-w")
    flags+=("--height")
    flags+=("--print")
    flags+=("-p")
    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-f")
    flags+=("--border=")
    two_word_flags+=("--border")
    two_word_flags+=("-b")
    flags+=("--border.foreground=")
    two_word_flags+=("--border.foreground")
    flags+=("--border.background=")
    two_word_flags+=("--border.background")
    flags+=("--cell.foreground=")
    two_word_flags+=("--cell.foreground")
    flags+=("--cell.background=")
    two_word_flags+=("--cell.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--selected.foreground=")
    two_word_flags+=("--selected.foreground")
    flags+=("--selected.background=")
    two_word_flags+=("--selected.background")

    noun_aliases=()
}

_gum.exe_write()
{
    last_command="gum.exe_write"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--width")
    flags+=("--height")
    flags+=("--header=")
    two_word_flags+=("--header")
    flags+=("--placeholder=")
    two_word_flags+=("--placeholder")
    flags+=("--prompt=")
    two_word_flags+=("--prompt")
    flags+=("--show-cursor-line")
    flags+=("--show-line-numbers")
    flags+=("--value=")
    two_word_flags+=("--value")
    flags+=("--char-limit")
    flags+=("--show-help")
    flags+=("--cursor.mode=")
    two_word_flags+=("--cursor.mode")
    flags+=("--base.foreground=")
    two_word_flags+=("--base.foreground")
    flags+=("--base.background=")
    two_word_flags+=("--base.background")
    flags+=("--cursor.foreground=")
    two_word_flags+=("--cursor.foreground")
    flags+=("--cursor.background=")
    two_word_flags+=("--cursor.background")
    flags+=("--header.foreground=")
    two_word_flags+=("--header.foreground")
    flags+=("--header.background=")
    two_word_flags+=("--header.background")
    flags+=("--placeholder.foreground=")
    two_word_flags+=("--placeholder.foreground")
    flags+=("--placeholder.background=")
    two_word_flags+=("--placeholder.background")
    flags+=("--prompt.foreground=")
    two_word_flags+=("--prompt.foreground")
    flags+=("--prompt.background=")
    two_word_flags+=("--prompt.background")
    flags+=("--end-of-buffer.foreground=")
    two_word_flags+=("--end-of-buffer.foreground")
    flags+=("--end-of-buffer.background=")
    two_word_flags+=("--end-of-buffer.background")
    flags+=("--line-number.foreground=")
    two_word_flags+=("--line-number.foreground")
    flags+=("--line-number.background=")
    two_word_flags+=("--line-number.background")
    flags+=("--cursor-line-number.foreground=")
    two_word_flags+=("--cursor-line-number.foreground")
    flags+=("--cursor-line-number.background=")
    two_word_flags+=("--cursor-line-number.background")
    flags+=("--cursor-line.foreground=")
    two_word_flags+=("--cursor-line.foreground")
    flags+=("--cursor-line.background=")
    two_word_flags+=("--cursor-line.background")

    noun_aliases=()
}

_gum.exe_log()
{
    last_command="gum.exe_log"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--file=")
    two_word_flags+=("--file")
    two_word_flags+=("-o")
    flags+=("--format")
    flags+=("-f")
    flags+=("--formatter=")
    two_word_flags+=("--formatter")
    flags+=("--level=")
    two_word_flags+=("--level")
    two_word_flags+=("-l")
    flags+=("--prefix=")
    two_word_flags+=("--prefix")
    flags+=("--structured")
    flags+=("-s")
    flags+=("--time=")
    two_word_flags+=("--time")
    two_word_flags+=("-t")
    flags+=("--level.foreground=")
    two_word_flags+=("--level.foreground")
    flags+=("--level.background=")
    two_word_flags+=("--level.background")
    flags+=("--time.foreground=")
    two_word_flags+=("--time.foreground")
    flags+=("--time.background=")
    two_word_flags+=("--time.background")
    flags+=("--prefix.foreground=")
    two_word_flags+=("--prefix.foreground")
    flags+=("--prefix.background=")
    two_word_flags+=("--prefix.background")
    flags+=("--message.foreground=")
    two_word_flags+=("--message.foreground")
    flags+=("--message.background=")
    two_word_flags+=("--message.background")
    flags+=("--key.foreground=")
    two_word_flags+=("--key.foreground")
    flags+=("--key.background=")
    two_word_flags+=("--key.background")
    flags+=("--value.foreground=")
    two_word_flags+=("--value.foreground")
    flags+=("--value.background=")
    two_word_flags+=("--value.background")
    flags+=("--separator.foreground=")
    two_word_flags+=("--separator.foreground")
    flags+=("--separator.background=")
    two_word_flags+=("--separator.background")

    noun_aliases=()
}

_gum.exe_root_command()
{
    last_command="gum.exe"

    command_aliases=()

    commands=()
    commands+=("choose")
    commands+=("confirm")
    commands+=("file")
    commands+=("filter")
    commands+=("format")
    commands+=("input")
    commands+=("join")
    commands+=("pager")
    commands+=("spin")
    commands+=("style")
    commands+=("table")
    commands+=("write")
    commands+=("log")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    flags+=("--version")
    flags+=("-v")

    noun_aliases=()
}

__start_gum.exe()
{
    local cur prev words cword split
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __gum.exe_init_completion -n "=" || return
    fi

    local c=0
    local flag_parsing_disabled=
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("gum.exe")
    local command_aliases=()
    local must_have_one_flag=()
    local must_have_one_noun=()
    local has_completion_function=""
    local last_command=""
    local nouns=()
    local noun_aliases=()

    __gum.exe_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_gum.exe gum.exe
else
    complete -o default -o nospace -F __start_gum.exe gum.exe
fi

# ex: ts=4 sw=4 et filetype=sh
