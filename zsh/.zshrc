export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="robbyrussell"
plugins=(git)

[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
source $ZDOTDIR/nvim-profile.sh
source $ZSH/oh-my-zsh.sh

alias gac="git add -A && git commit -am"

