#!/usr/bin/env bash

# Source: - https://learn.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete#bash
# cSpell: disable

if command -v dotnet >/dev/null 2>&1; then
  # bash parameter completion for the dotnet CLI

  function _dotnet_bash_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n' # On Windows you may need to use use IFS=$'\r\n'
    local candidates

    read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)

    read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
  }

  complete -f -F _dotnet_bash_complete dotnet
fi
