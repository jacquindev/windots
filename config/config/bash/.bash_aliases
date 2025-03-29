# clear
alias c='clear'
alias cls='clear'

# exit
alias q='exit'
alias quit='exit'

alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# list declared aliases, functions, paths
alias aliases="alias | sed 's/=.*//'"
alias functions="declare -f | grep '^[a-z].* ()' | sed 's/{$//'"
alias paths='echo $PATH | tr ":" "\n"'

# reload shell
alias reload='exec $SHELL -l'

# history
alias h='history'
alias hist-clr='echo "" > ~/.bash_history'

# common locations
alias dotf="cd $DOTFILES"
alias docs="cd ~/Documents"
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"

# disk usage
alias dux='du -x --max-depth=1 | sort -n'
alias dud='du -d 1 -h'
alias duf='du -sh *'

# ip address
alias ip="curl -s ipinfo.io | jq -r '.ip'"

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

if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
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
fi

#   lr:  Full Recursive Directory Listing
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

# urlencode / urldecode
if command -v node >/dev/null 2>&1; then
  alias urlencode='node -e "console.log(encodeURIComponent(process.argv[1]))"'
  alias urldecode='node -e "console.log(decodeURIComponent(process.argv[1]))"'
else
  alias urlencode='python3 -c "import sys; del sys.path[0]; import urllib.parse as up; print(up.quote_plus(sys.argv[1]))"'
  alias urldecode='python3 -c "import sys; del sys.path[0]; import urllib.parse as up; print(up.unquote_plus(sys.argv[1]))"'
fi
