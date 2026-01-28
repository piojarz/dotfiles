#!/usr/bin/env bash

# macOS specific setup functions
# This script is sourced by the main install.sh

setup_homebrew() {
  title "Setting up Homebrew and Casks"
  
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to path for the current session
    if [[ $(uname -m) == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    info "Homebrew already installed, updating..."
    brew update
  fi

  info "Installing GUI applications from Brewfile..."
  # The Brewfile is in the root of the repo
  brew bundle --file="$(dirname "${BASH_SOURCE[0]}")/../../Brewfile"
}

setup_macos_preferences() {
  title "Applying macOS System Preferences"
  
  # Delegate to the system-preferences.sh script which contains the defaults write commands
  local pref_script="$(dirname "${BASH_SOURCE[0]}")/system-preferences.sh"
  if [[ -f "$pref_script" ]]; then
    bash "$pref_script"
  else
    warning "System preferences script not found at $pref_script"
  fi
}
