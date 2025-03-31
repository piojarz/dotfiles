#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_arch() {
  title "Setting up Arch Linux"
  
  # Update system
  info "Updating system"
  sudo pacman -Syu --noconfirm

  # Install base packages
  install_package "base-devel git curl wget unzip" "pacman"

  # Install AUR helper (yay)
  if ! command -v yay &> /dev/null; then
    info "Installing yay AUR helper"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
  fi

  # Core packages
  local core_packages=(
    kitty zsh firefox vlc anki
    git xclip git-lfs delta
    sqlite3 stow bat cloc entr eza fd fzf gnupg grep highlight htop jq neofetch neovim python ripgrep shellcheck tmux tree wdiff wget zoxide zsh
  )
  
  for package in "${core_packages[@]}"; do
    install_package "$package" "pacman"
  done

  # AUR packages
  local aur_packages=(
    zsh-antidote
    code
    atuin
    lazygit
    glow
    google-chrome
    1password-cli
  )
  
  for package in "${aur_packages[@]}"; do
    info "Installing AUR package: $package"
    yay -S --noconfirm "$package"
  done

  # Docker setup
  install_package "docker" "pacman"
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ${USER}

  # Tmux Plugin Manager
  git clone https://github.com/tmux-plugins/tpm ~/config/.tmux/plugins/tpm

  # missing slack sourcetree spotify notion lua luarocks stylua

  # fnm (Node.js version manager)
  curl -fsSL https://fnm.vercel.app/install | bash
} 