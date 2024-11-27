export DOTFILES="$(dirname $(dirname $(readlink ~/.bashrc)))"

# gsudo wrapper
function sudo() {
  WSLENV=WSL_DISTRO_NAME:USER:$WSLENV MSYS_NO_PATHCONV=1 gsudo.exe "$@"
}

# oh-my-posh
if command -v oh-my-posh >/dev/null 2>&1; then
  alias omp='oh-my-posh'
  eval "$(oh-my-posh init bash --config $DOTFILES/home/bash-zen.toml)"
fi

# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi
