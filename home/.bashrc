export DOTFILES="$(dirname $(dirname $(readlink ~/.bashrc)))"

# general aliases
alias reload="exec $SHELL -l"
alias c='clear'

alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

mkcd() {
  mkdir "$@" && cd "$@"
}

# gsudo wrapper
sudo() {
  WSLENV=WSL_DISTRO_NAME:USER:$WSLENV MSYS_NO_PATHCONV=1 gsudo.exe "$@"
}

# chmod:
# Stolen from: - https://github.com/ohmybash/oh-my-bash/blob/master/aliases/chmod.aliases.sh
alias perm='stat --printf "%a %n \n "' # Show permission of target in number
alias 000='chmod 000'                  # ---------- (nobody)
alias 640='chmod 640'                  # -rw-r----- (user: rw, group: r)
alias 644='chmod 644'                  # -rw-r--r-- (user: rw, group: r, other: r)
alias 755='chmod 755'                  # -rwxr-xr-x (user: rwx, group: rx, other: rx)
alias 775='chmod 775'                  # -rwxrwxr-x (user: rwx, group: rwx, other: rx)
alias mx='chmod a+x'                   # ---x--x--x (user: --x, group: --x, other: --x)
alias ux='chmod u+x'                   # ---x------ (user: --x, group: -, other: -)

# git
alias g='git'
\. /mingw64/share/git/completion/git-completion.bash

# docker
if command -v docker >/dev/null 2>&1; then
  alias d='docker'
  source <(docker completion bash)
fi

# kubectl
if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
  source <(kubectl completion bash)
fi

# pip
if command -v pip >/dev/null 2>&1; then
  source <(pip completion --bash)
fi
