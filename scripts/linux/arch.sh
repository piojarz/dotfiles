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
    sqlite3 stow bat cloc entr eza fd fzf gnupg grep highlight htop jq neofetch neovim python ripgrep shellcheck sesh-bin tmux tree wdiff wget zoxide zsh
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
    slack-desktop
    sourcetree
    spotify
    notion-app-electron
    luarocks
    stylua
    kanata-bin
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



  # Setup fonts
  source "$(dirname "${BASH_SOURCE[0]}")/fonts.sh"
  setup_fonts

  # fnm (Node.js version manager)
  curl -fsSL https://fnm.vercel.app/install | bash

  # Setup kanata keyboard remapping
  setup_kanata_linux
}

setup_kanata_linux() {
  title "Setting up Kanata keyboard remapping"
  
  # Ensure uinput module is loaded
  if ! lsmod | grep -q uinput; then
    info "Loading uinput kernel module..."
    sudo modprobe uinput
  fi
  
  # Ensure user has access to input devices
  if ! groups $USER | grep -q input; then
    info "Adding user to input group..."
    sudo usermod -aG input $USER
  fi
  
  # Create systemd user service for kanata
  local systemd_user_dir="$HOME/.config/systemd/user"
  ensure_directory "$systemd_user_dir"
  
  cat > "$systemd_user_dir/kanata.service" << 'EOF'
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=/usr/bin/kanata --cfg %h/.config/kanata/kanata.kbd
Restart=no

[Install]
WantedBy=default.target
EOF
  
  # Reload systemd user daemon
  systemctl --user daemon-reload
  
  success "Kanata systemd service created"
  info "To enable kanata on startup: systemctl --user enable kanata.service"
  info "To start kanata now: systemctl --user start kanata.service"
  info "Note: You may need to log out and back in for input group changes to take effect"
} 