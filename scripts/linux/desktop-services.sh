#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

# Hyprland desktop services setup - Nix handles packages
# This script only handles system services that Nix can't manage

setup_desktop_services() {
  title "Configuring Hyprland desktop services"
  
  # Enable system services for desktop environment
  info "Setting up desktop environment services"
  
  # Enable polkit agent for authentication
  if ! pgrep -u "$USER" polkit-kde-authentication-agent-1 > /dev/null; then
    info "Enabling polkit agent"
    systemctl --user enable polkit-kde-authentication-agent-1
  fi
  
  # Enable clipboard history service
  if ! pgrep -u "$USER" cliphist > /dev/null; then
    info "Enabling clipboard history"
    systemctl --user enable cliphist
  fi
  
  # Setup desktop portal integration
  info "Configuring desktop portals"
  systemctl --user enable xdg-desktop-portal-hyprland
  
  # Enable NetworkManager applet
  if command -v blueman > /dev/null; then
    info "Configuring network management"
    systemctl --user enable blueman
  fi
}

setup_wayland_environment() {
  info "Configuring Wayland environment"
  
  # Set up environment variables for Wayland
  if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR=/tmp/xdg-runtime-"$USER"
  fi
  
  info "Wayland environment configured"
}

# Configure notifications service
setup_notifications() {
  info "Configuring notification service"
  
  # Enable mako notification service
  systemctl --user enable mako
  
  success "Notification service configured"
}

main() {
  setup_wayland_environment
  setup_desktop_services
  setup_notifications
  
  success "Hyprland desktop services setup complete"
  info "Desktop environment configuration is now handled by Nix Home Manager"
  info "Apply Nix configuration with: home-manager switch --flake .#linux-desktop"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi