#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

# System-level setup for Arch Linux - Nix handles packages
# This script only handles system services and AUR helpers that Nix can't manage

setup_arch_system() {
  title "Setting up Arch Linux system services"
  
  # Update system
  info "Updating system packages"
  sudo pacman -Syu --noconfirm
  
  # Install AUR helper (yay) - Nix can't install this
  if ! command -v yay &> /dev/null; then
    info "Installing yay AUR helper"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
  fi
  
  # Install system services that Nix can't easily manage
  info "Setting up system services"
  
  # Enable essential services
  if systemctl is-enabled --quiet systemd-resolved; then
    info "systemd-resolved already enabled"
  else
    info "Enabling systemd-resolved"
    sudo systemctl enable systemd-resolved
  fi
  
  # Set up user services
  setup_user_services
}

setup_user_services() {
  # Only handle services, not packages
  info "Configuring user services"
  
  # Enable user dbus if not running
  if ! pgrep -u "$USER" dbus-daemon > /dev/null; then
    info "Enabling user dbus"
    systemctl --user enable dbus
  fi
}

# Font installation - keep this as Nix font handling is complex
setup_fonts() {
  if [ "$SETUP_FONTS" = "true" ]; then
    info "Installing fonts"
    sudo pacman -S --noconfirm \
      noto-fonts \
      ttf-font-awesome \
      ttf-jetbrains-mono \
      ttf-fira-code \
      ttf-fira-sans
  fi
}

main() {
  setup_arch_system
  setup_fonts
  
  success "Arch Linux system setup complete"
  info "Package management is now handled by Nix Home Manager"
  info "Apply Nix configuration with: home-manager switch --flake .#linux-desktop"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi