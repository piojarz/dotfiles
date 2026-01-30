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
  
  # Install all font packages at once (more efficient)
  install_package "pacman" "${font_packages[@]}"
  
  # Install AUR fonts
  local aur_fonts=(
    ttf-ms-fonts
    ttf-vista-fonts
  )
  
  # Install AUR fonts at once (more efficient)
  if [[ ${#aur_fonts[@]} -gt 0 ]]; then
    info "Installing AUR fonts: ${aur_fonts[*]}"
    yay -S --noconfirm "${aur_fonts[@]}"
  fi
  
  # Rebuild font cache
  info "Rebuilding font cache"
  fc-cache -fv
  
  success "Font installation complete"
}