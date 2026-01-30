#!/usr/bin/env zsh

# fix typos
alias quit='exit'
alias cd..='cd ..'
alias zz='exit'

# Reload zsh config
alias reload!="RELOAD=1 source $XDG_CONFIG_HOME/zsh/.zshrc"
alias zshrc="${EDITOR:-vim} "${ZDOTDIR:-$HOME}"/.zshrc"
alias zdot='cd $ZDOTDIR'

# Dotfiles
alias dotf='cd "$DOTFILES"'
alias dotfed='cd "$DOTFILES" && ${VISUAL:-${EDITOR:-vim}} .'

# Filesystem aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder
alias lpath='echo $PATH | tr ":" "\n"' # list the PATH separated by new lines

# Platform-specific aliases
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS-specific aliases
  # Hide/show all desktop icons (useful when presenting)
  alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
  alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
  
  # Recursively delete `.DS_Store` files (macOS only)
  alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
fi
# remove broken symlinks
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

# use eza if available
alias ll="eza --icons --git --long"
alias l="eza --icons --git --all --long"

alias rmf="rm -rf"

# tmux aliases
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'

alias cat="bat"

# single character shortcuts - be sparing!
alias _=sudo

# Platform-specific open command
if [[ "$(uname)" == "Darwin" ]]; then
  alias o=open
else
  alias o=xdg-open
fi

alias g=git

alias vim="nvim"
alias nr='node run'