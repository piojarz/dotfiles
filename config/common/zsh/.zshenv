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
  # No dotfiles directory found - set to a sane default but warn user
  export DOTFILES=$HOME/.config
  echo "Warning: Dotfiles directory not found in expected locations." >&2
  echo "Please clone your dotfiles to ~/dotfiles or ~/.dotfiles" >&2
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

# Wayland-specific environment variables (Linux only, and only when running under Wayland)
if [[ "$(uname)" != "Darwin" ]]; then
  # Check if running under Wayland
  if [[ -n "$WAYLAND_DISPLAY" ]] || [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # Firefox native Wayland support
    export MOZ_ENABLE_WAYLAND=1
    
    # Qt applications
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=gtk2
    
    # SDL applications
    export SDL_VIDEODRIVER=wayland
    
    # Java applications
    export _JAVA_AWT_WM_NONREPARENTING=1
    
    # Cliphist (clipboard history) - ignore sensitive patterns
    # Use regex pattern with word boundaries
    export CLIPHIST_IGNORE="password|secret|key|token|api_key|private_key|credential"
    
    # Set desktop environment only if not already set
    if [[ -z "$XDG_CURRENT_DESKTOP" ]]; then
      export XDG_CURRENT_DESKTOP=Hyprland
    fi
    if [[ -z "$XDG_SESSION_DESKTOP" ]]; then
      export XDG_SESSION_DESKTOP=Hyprland
    fi
  fi
fi
