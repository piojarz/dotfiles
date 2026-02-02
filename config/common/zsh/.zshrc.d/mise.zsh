#!/bin/zsh
# mise initialization
# Fast version manager (replaces asdf)

# Only initialize mise if it's installed
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi
