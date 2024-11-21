export DOTFILES="$(dirname $(dirname $(readlink ~/.bashrc)))"

# general aliases
alias reload="exec $SHELL -l"
alias c='clear'

alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias paths='echo $PATH | tr ":" "\n"'

alias reload='exec $SHELL -l'

mkcd() {
  mkdir "$@" && cd "$@" || exit
}

# gsudo wrapper
sudo() {
  WSLENV=WSL_DISTRO_NAME:USER:$WSLENV MSYS_NO_PATHCONV=1 gsudo.exe "$@"
}

# common locations
alias dotf="cd $DOTFILES"
alias docs="cd $USERPROFILE/Documents"
alias desktop="cd $USERPROFILE/Desktop"
alias downloads="cd $USERPROFILE/Downloads"
alias home="cd $USERPROFILE"

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

if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi

# oh-my-posh
if command -v oh-my-posh >/dev/null 2>&1; then
  alias omp='oh-my-posh'
  source <(oh-my-posh completion bash)
  eval "$(oh-my-posh init bash --config $DOTFILES/home/bash-zen.toml)"
fi

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --git --icons --group --group-directories-first --time-style=long-iso --color-scale=all'
  alias l='ls --git-ignore'
  alias ll='ls --all --header --long'
  alias lm='ls --all --header --long --sort=modified'
  alias la='ls -lbhHigUmuSa'
  alias lx='ls -lbhHigUmuSa@'
  alias lt='eza --all --icons --group --group-directories-first --tree --color-scale=all'
  alias tree='ls --tree'
else
  alias dir='ls -hFx'
  alias ls='ls --color=auto'
  alias l='ls -CF'
  alias lm='ls -al | more'
  alias ll='ls -lAFh'
  alias la='ls -Al'

  #   lr:  Full Recursive Directory Listing
  alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
fi

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

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi
