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

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
# remove broken symlinks
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

# use eza if available
if [[ -x "$(command -v eza)" ]]; then
  alias ll="eza --icons --git --long"
  alias l="eza --icons --git --all --long"
else
  alias l="ls -lah ${colorflag}"
  alias ll="ls -lFh ${colorflag}"
fi

# single character shortcuts - be sparing!
alias _=sudo
alias l="eza --icons --git"
alias o=open
alias g=git

alias vim="nvim"
alias nr='node run'