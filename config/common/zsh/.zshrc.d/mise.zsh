#!/bin/zsh
# mise initialization
# Fast version manager (replaces asdf)

(( $+commands[mise] )) || return 1
eval "$(mise activate zsh)"
