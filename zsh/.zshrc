export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="robbyrussell"
plugins=(git)

[[ -f "$HOME/.config/zsh/.zshrc.local" ]] && source "$HOME/.config/zsh/.zshrc.local"
source $ZSH/oh-my-zsh.sh

alias gac="git add -A && git commit -am"

