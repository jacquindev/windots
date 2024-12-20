#!/usr/bin/env bash

if ! command -v pip >/dev/null 2>&1; then return; fi

# pip bash completion start
_pip_completion() {
	COMPREPLY=($(COMP_WORDS="${COMP_WORDS[*]}" \
		COMP_CWORD=$COMP_CWORD \
		PIP_AUTO_COMPLETE=1 $1 2>/dev/null))
}
complete -o default -F _pip_completion pip
complete -o default -F _pip_completion pip3
# pip bash completion end
