#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

# System-level setup for Arch Linux - Nix handles packages
# This script only handles system services and AUR helpers that Nix can't manage

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
  
  # Install Desktop Environment if requested
  if [[ "${SETUP_DESKTOP:-false}" == "true" ]]; then
    setup_desktop_environment
  fi
}

setup_desktop_environment() {
  title "Installing Desktop Environment (Hyprland + SDDM)"
  
  info "Installing system-level dependencies for Wayland/Hyprland"
  
  # Base requirements
  local packages=(
    hyprland sddm qt5-wayland qt6-wayland xdg-desktop-portal-hyprland
    polkit-kde-authentication-agent-1 mesa lib32-mesa
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
    network-manager-applet bluez bluez-utils blueman
    brightnessctl pamixer playerctl thunar gvfs tumbler
  )
  
  # GPU Drivers detection
  if lscpu | grep -qi "Intel"; then
    info "Intel GPU detected, adding drivers..."
    packages+=(xf86-video-intel vulkan-intel libva-intel-driver)
  fi
  
  if lspci | grep -qi "AMD"; then
    info "AMD GPU detected, adding drivers..."
    packages+=(xf86-video-amdgpu vulkan-radeon libva-mesa-driver)
  fi
  
  if lspci | grep -qi "NVIDIA"; then
    info "NVIDIA GPU detected, adding drivers..."
    packages+=(nvidia nvidia-utils nvidia-settings lib32-nvidia-utils)
    warning "NVIDIA detected. You may need to add 'nvidia-drm.modeset=1' to your kernel parameters."
  fi
  
  sudo pacman -S --noconfirm "${packages[@]}"
  
  info "Configuring user permissions"
  # Add user to video and render groups for GPU access
  sudo usermod -aG video,render "$USER"
  
  info "Enabling system services"
  sudo systemctl enable sddm
  sudo systemctl enable bluetooth
  sudo systemctl enable NetworkManager
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