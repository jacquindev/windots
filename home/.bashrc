# cSpell:disable

export DOTFILES="$(dirname $(dirname $(readlink ~/.bashrc)))"

# Source external files
test -f ~/.config/bash/.bash_env && . ~/.config/bash/.bash_env
test -f ~/.config/bash/.bash_aliases && . ~/.config/bash/.bash_aliases
test -f ~/.config/bash/.bash_completions && . ~/.config/bash/.bash_completions
test -f ~/.config/bash/.bash_functions && . ~/.config/bash/.bash_functions

# Bash shell settings
shopt -s autocd
shopt -s cdspell
shopt -s checkwinsize
shopt -s direxpand dirspell
shopt -s extglob
shopt -s globstar
shopt -s no_empty_cmd_completion
shopt -s nocaseglob

# History
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
HISTFILESIZE=10000
HISTSIZE=10000
shopt -s cmdhist
shopt -s histappend histverify

# oh-my-posh
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init bash --config $DOTFILES/home/bash-zen.toml)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)"
fi

# fastfetch
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
