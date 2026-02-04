#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_linux() {
  title "Setting up Linux Tools"
  
  # Core packages not covered by danklinux
  local core_packages=(
    kitty
    git
    git-lfs
    git-delta
    firefox
    vlc
    zsh
    btop
    bat
    eza
    fd
    fzf
    jq
    ripgrep
    shellcheck
    stow
    tmux
    tree
    zoxide
    neovim
    python
    sqlite3
  )
  
  info "Installing core tools..."
  install_package "pacman" "${core_packages[@]}"

  # AUR packages
  local aur_packages=(
    zsh-antidote
    code
    atuin
    lazygit
    glow
    google-chrome
    slack-desktop
    sourcetree
    spotify
    notion-app-electron
    1password-cli
    luarocks
    stylua
    kanata-bin
    sesh-bin
    mise
    yazi
    zellij
    starship
    fastfetch
  )
  
  if command -v yay &> /dev/null; then
    info "Installing AUR packages..."
    yay -S --noconfirm "${aur_packages[@]}"
  else
    warning "yay not found, skipping AUR packages. Please install yay or another AUR helper."
  fi

  # Setup fonts
  setup_linux_fonts

  # Setup kanata keyboard remapping
  setup_kanata_linux

  success "Linux tool configuration complete!"
}

setup_linux_fonts() {
  title "Setting up fonts"
  
  local font_packages=(
    ttf-fira-code
    ttf-hack
    ttf-jetbrains-mono
    ttf-cascadia-code
    ttf-recursive-nerd
    ttf-font-awesome
    noto-fonts
    noto-fonts-emoji
  )
  
  info "Installing fonts..."
  install_package "pacman" "${font_packages[@]}"
  
  if command -v fc-cache &> /dev/null; then
    info "Rebuilding font cache..."
    fc-cache -fv
  fi
}

setup_kanata_linux() {
  title "Setting up Kanata"
  
  # Ensure user has access to input devices
  if ! groups "$USER" | grep -q input; then
    info "Adding user to input group..."
    sudo usermod -aG input "$USER"
    info "Note: You may need to log out and back in for group changes to take effect"
  fi
  
  # Create systemd user service for kanata
  local kanata_bin
  kanata_bin=$(which kanata 2>/dev/null || echo "/usr/bin/kanata")
  
  local systemd_user_dir="$HOME/.config/systemd/user"
  ensure_directory "$systemd_user_dir"
  
  cat > "$systemd_user_dir/kanata.service" << EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=${kanata_bin} --cfg %h/.config/kanata/kanata.kbd
Restart=no

[Install]
WantedBy=default.target
EOF
  
  systemctl --user daemon-reload
  success "Kanata systemd service created"
}