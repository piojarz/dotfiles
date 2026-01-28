#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

# macOS system preferences setup - Nix handles packages
# This script only handles system preferences Nix can't manage

setup_homebrew_bridge() {
  title "Setting up Homebrew bridge"
  
  # Homebrew setup only for GUI apps not available via Nix
  if test ! "$(command -v brew)"; then
    info "Homebrew not installed. Installing for GUI applications."
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
  fi
  
  # Only install GUI apps that Nix can't provide
  info "Homebrew is now only used for GUI applications"
  info "All CLI tools are managed by Nix Home Manager"
}

# System preferences that Nix can't handle
set_system_preferences() {
  info "Configuring macOS system preferences"
  
  # General system preferences
  defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write NSGlobalDomain AppleShowAllFiles -bool true
  
  # Security and privacy
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  
  # Input and trackpad
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  
  # Finder preferences
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  
  # Dock preferences
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock orientation -string "bottom"
  
  success "macOS system preferences configured"
}

set_finder_preferences() {
  # These are also system preferences, keeping them separate for clarity
  defaults write com.apple.finder QuitMenuItem -bool true
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
}

set_dock_preferences() {
  # Additional dock settings
  defaults write com.apple.dock tilesize -int 1
  defaults write com.apple.dock minimize-to-application -bool true
}

setup_keyboard_preferences() {
  info "Configuring keyboard preferences"
  
  # Keyboard settings that Nix might not handle
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain KeyRepeat -int 2
  
  success "Keyboard preferences configured"
}

main() {
  setup_homebrew_bridge
  setup_system_preferences
  setup_keyboard_preferences
  
  success "macOS system setup complete"
  info "Package management is now handled by Nix Home Manager"
  info "Apply Nix configuration with: home-manager switch --flake .#macos-laptop"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi