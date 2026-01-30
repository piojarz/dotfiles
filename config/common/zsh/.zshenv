#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.
#

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

# Set ZDOTDIR if you want to re-home Zsh.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
# Detect dotfiles repository location
# Check common locations in order of preference
if [[ -d "$HOME/dotfiles" ]]; then
  export DOTFILES=$HOME/dotfiles
elif [[ -d "$HOME/.dotfiles" ]]; then
  export DOTFILES=$HOME/.dotfiles
elif [[ -d "$HOME/.config/dotfiles" ]]; then
  export DOTFILES=$HOME/.config/dotfiles
else
  # Fallback to XDG_CONFIG_HOME
  export DOTFILES=$XDG_CONFIG_HOME
fi

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Set the list of directories that zsh searches for commands.
path=(
  $HOME/{,s}bin(N)
  $HOME/.local/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

# Wayland-specific environment variables (Linux only)
if [[ "$(uname)" != "Darwin" ]]; then
  # Firefox native Wayland support
  export MOZ_ENABLE_WAYLAND=1
  
  # Qt applications
  export QT_QPA_PLATFORM=wayland
  export QT_QPA_PLATFORMTHEME=gtk2
  
  # SDL applications
  export SDL_VIDEODRIVER=wayland
  
  # Java applications
  export _JAVA_AWT_WM_NONREPARENTING=1
  
  # Set desktop environment
  export XDG_CURRENT_DESKTOP=Hyprland
  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=Hyprland
  
  # Cliphist (clipboard history)
  export CLIPHIST_IGNORE="passwordsecretkeytoken"
fi
