#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

# System-level setup for Arch Linux - Nix handles applications
# This script only handles system services that archinstall doesn't configure
# 
# PREREQUISITE: Install Hyprland + SDDM via archinstall first:
# - wayland hyprland sddm (and GPU drivers if offered)
# 
# This script then configures: system services, user permissions, AUR helper

setup_arch_system() {
  title "Setting up Arch Linux system services"
  
  # Enable multilib if not enabled
  if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    info "Enabling multilib repository..."
    sudo sed -i '/^#\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    sudo pacman -Sy
  fi

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
  
  # Install Desktop Environment (Hyprland + SDDM)
  setup_desktop_environment
}

setup_desktop_environment() {
  title "Configuring Desktop Environment (Assumes Hyprland installed via archinstall)"
  
  info "Setting up system services for Wayland/Hyprland"
  
  # Note: Hyprland, SDDM, and base Wayland packages should be installed via archinstall
  # This script only handles system services and configuration that archinstall can't do
  
  info "Configuring user permissions"
  # Add user to video and render groups for GPU access
  sudo usermod -aG video,render "$USER"
  
  info "Enabling system services"
  sudo systemctl enable sddm
  sudo systemctl enable bluetooth
  sudo systemctl enable NetworkManager
  sudo systemctl set-default graphical.target
  
  # Install system-level services that archinstall typically doesn't include
  local service_packages=(
    polkit-kde-authentication-agent-1
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    network-manager-applet bluez bluez-utils blueman
  )
  
  sudo pacman -S --noconfirm "${service_packages[@]}"
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
    info "Skipping system font installation - fonts are managed by Nix Home Manager"
    info "To install system fonts manually, uncomment the section below"
    # sudo pacman -S --noconfirm \
    #   noto-fonts \
    #   ttf-font-awesome \
    #   ttf-jetbrains-mono \
    #   ttf-fira-code \
    #   ttf-fira-sans
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