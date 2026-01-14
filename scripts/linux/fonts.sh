#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_fonts() {
  title "Setting up fonts on Arch Linux"
  
  # Install base font packages
  local font_packages=(
    ttf-fira-code
    ttf-hack
    ttf-jetbrains-mono
    ttf-cascadia-code
    ttf-recursive-std
    ttf-font-awesome
    noto-fonts
    noto-fonts-emoji
  )
  
  for package in "${font_packages[@]}"; do
    install_package "$package" "pacman"
  done
  
  # Install AUR fonts
  local aur_fonts=(
    ttf-ms-fonts
    ttf-vista-fonts
  )
  
  for font in "${aur_fonts[@]}"; do
    info "Installing AUR font: $font"
    yay -S --noconfirm "$font"
  done
  
  # Rebuild font cache
  info "Rebuilding font cache"
  fc-cache -fv
  
  success "Font installation complete"
}