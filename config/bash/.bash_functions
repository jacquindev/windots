#!/usr/bin/env bash

# cSpell: disable

# gsudo wrapper:
# - https://gerardog.github.io/gsudo/docs/usage/bash-for-windows
function gsudo() {
  WSLENV=WSL_DISTRO_NAME:USER:$WSLENV MSYS_NO_PATHCONV=1 gsudo.exe "$@"
}

# yazi
# - https://yazi-rs.github.io/docs/quick-start
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Extract file
# - https://github.com/xvoland/Extract/blob/master/extract.sh
# - https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/extract/extract.plugin.zsh
function extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract [file ...] - Extract compressed files"
    echo "       extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 0
  fi

  for n in "$@"; do
    if [ -f "$n" ]; then
      case "${n%,}" in
      *.7z | *.apk | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.dmg | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar) 7z x ./"$n" ;;
      *.bz2) bunzip2 ./"$n" ;;
      *.cbr | *.rar) unrar x -ad ./"$n" ;;
      *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar) tar xvf "$n" ;;
      *.gz) gunzip ./"$n" ;;
      *.tar.zst | *.tzst) tar --zstd --help >/dev/null 2>&1 && tar --zstd -xvf "$n" ;;
      *.xz) unxz ./"$n" ;;
      *.z) uncompress ./"$n" ;;
      *.zip | *.war | *.jar | *.ear | *.sublime-package | *.ipa | *.ipsw | *.xpi | *.apk | *.aar | *.whl | *.vsix | *.crx | *.cbz | *.epub) unzip ./"$n" ;;
      esac
    else
      echo "$n - file does not exist"
      return 1
    fi
  done
}

# Create a directory and `cd` to it
function mkcd() {
  if [ -z "$1" ]; then
    echo "Usage: mkcd [path / directory name] - Create a directory and change into it"
    return 0
  else
    mkdir -p "$1" && cd "$1" || exit
  fi
}

# Open file/URL in Microsoft Edge
function edge() {
  if [ -z "$1" ]; then
    echo "Usage: edge [url] - Open file/url in Microsoft Edge"
    return 0
  fi

  start microsoft-edge:"$1"
}

# Find real url from shorted url
function unshorten() {
  if [ -z "$1" ]; then
    echo "Usage: unshorten [url] - Find real url from shortened link"
    return 0
  fi

  curl -sIL $1 | sed -n 's/Location: *//p'
}
