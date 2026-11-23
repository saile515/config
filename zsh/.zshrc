export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="robbyrussell"
plugins=(git)

[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
source $ZDOTDIR/nvim-profile.sh
source $ZSH/oh-my-zsh.sh

alias gac="git add -A && git commit -am"

export PATH="/home/ej/.local/bin:$PATH"
export CMAKE_EXPORT_COMPILE_COMMANDS=1
