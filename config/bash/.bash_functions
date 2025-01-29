#!/usr/bin/env bash

# gsudo wrapper for Bash
# https://gerardog.github.io/gsudo/docs/usage/bash-for-windows#bash-profile-config
gsudo() { WSLENV=WSL_DISTRO_NAME:USER:$WSLENV MSYS_NO_PATHCONV=1 gsudo.exe "$@"; }

# yazi wrapper
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
y() {
	local tmp
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd" || exit 0
	fi
	rm -f -- "$tmp"
}

# mkcd: create a directory and `cd` to it
mkcd() {
	if [[ -z "$1" ]]; then
		echo "Usage: mkcd [path / directory name] - Create a directory and change into it"
		return 0
	else
		mkdir -p "$1" && cd "$1" || exit 0
	fi
}

# edge: Open file/URL in Microsoft Edge
edge() {
	if [[ -z "$1" ]]; then
		echo "Usage: edge [url] - Open file/url in Microsoft Edge"
		return 0
	fi

	start microsoft-edge:"$1"
}

# unshorten: Find real url from shorted url
unshorten() {
	if [[ -z "$1" ]]; then
		echo "Usage: unshorten [url] - Find real url from shortened link"
		return 0
	fi

	curl -sIL "$1" | sed -n 's/Location: *//p'
}
