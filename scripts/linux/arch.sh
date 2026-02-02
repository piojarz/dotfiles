#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_arch() {
  title "Setting up Arch Linux"
  
  # Update system
  info "Updating system"
  sudo pacman -Syu --noconfirm

  # Install base packages
  install_package "pacman" base-devel git curl wget unzip

  # Install AUR helper (yay)
  if ! command -v yay &> /dev/null; then
    info "Installing yay AUR helper"
    local temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay"
    makepkg -si --noconfirm
    cd -
    rm -rf "$temp_dir"
  fi

  # Core packages
  local core_packages=(
    kitty zsh firefox vlc
    git xclip git-lfs git-delta
    sqlite3 stow bat cloc entr eza fd fzf gnupg grep highlight btop jq neovim python ripgrep shellcheck tmux tree wdiff wget zoxide zsh
    # Hyprland ecosystem
    hyprland hyprpaper hyprlock hypridle
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    qt5-wayland qt6-wayland
    polkit-kde-agent
    xorg-xwayland
    # Wayland utilities
    wl-clipboard cliphist
    mako libnotify
    grim slurp
    brightnessctl
    playerctl
    papirus-icon-theme
  )
  
  # Install all core packages at once (more efficient)
  install_package "pacman" "${core_packages[@]}"

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
    sesh-bin
    # Modern replacements
    mise # fast version manager (replaces asdf)
    btop # better system monitor (replaces htop)
    fastfetch # fast system info (replaces neofetch)
    yazi # blazing fast file manager
    zellij # modern terminal multiplexer
    starship # fast shell prompt (replaces oh-my-posh)
    # anki
    # Hyprland AUR packages
    hyprpanel
    rofi-wayland
    # Wayland utilities (AUR)
    wlogout
  )
  
  # Install all AUR packages at once (more efficient)
  if [[ ${#aur_packages[@]} -gt 0 ]]; then
    info "Installing AUR packages: ${aur_packages[*]}"
    yay -S --noconfirm "${aur_packages[@]}"
  fi

  # Docker setup
  install_package "pacman" docker
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ${USER}

  # Tmux Plugin Manager (idempotent check)
  if [[ ! -d ~/.config/tmux/plugins/tpm ]]; then
    info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  else
    info "TPM already installed, skipping..."
  fi

  # Setup fonts
  source "$(dirname "${BASH_SOURCE[0]}")/fonts.sh"
  setup_fonts

  # Note: mise handles all language version management (replaces fnm, asdf, etc.)

  # Setup kanata keyboard remapping (idempotent check)
  if ! command -v kanata &> /dev/null; then
    setup_kanata_linux
  else
    info "Kanata already installed, skipping setup..."
    setup_kanata_service_only
  fi

  # Setup Hyprland
  setup_hyprland

  # Setup Noctalia Shell (optional)
  source "$(dirname "${BASH_SOURCE[0]}")/noctalia.sh"
  setup_noctalia_shell
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
  
  # Find kanata binary location
  local kanata_bin
  kanata_bin=$(which kanata 2>/dev/null || echo "/usr/bin/kanata")
  
  # Create systemd user service for kanata
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
  
  # Reload systemd user daemon
  systemctl --user daemon-reload
  
  success "Kanata systemd service created"
  info "To enable kanata on startup: systemctl --user enable kanata.service"
  info "To start kanata now: systemctl --user start kanata.service"
  info "Note: You may need to log out and back in for input group changes to take effect"
}

setup_kanata_service_only() {
  title "Updating Kanata systemd service"
  
  # Only create/update the systemd service file if it doesn't exist
  local systemd_user_dir="$HOME/.config/systemd/user"
  local service_file="$systemd_user_dir/kanata.service"
  
  # Find kanata binary location
  local kanata_bin
  kanata_bin=$(which kanata 2>/dev/null || echo "/usr/bin/kanata")
  
  if [[ ! -f "$service_file" ]]; then
    info "Creating kanata systemd service file..."
    ensure_directory "$systemd_user_dir"
    
    cat > "$service_file" << EOF
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
    info "To enable kanata on startup: systemctl --user enable kanata.service"
  else
    info "Kanata service file already exists, skipping..."
  fi
}

setup_hyprland() {
  title "Setting up Hyprland"
  
  # Create wallpapers directory
  if [[ ! -d "$HOME/wallpapers" ]]; then
    info "Creating wallpapers directory..."
    mkdir -p "$HOME/wallpapers"
    info "Place your wallpaper at ~/wallpapers/default.jpg"
  fi
  
  # Setup auto-start on TTY login
  setup_hyprland_autostart
  
  success "Hyprland setup complete!"
  info "To start Hyprland:"
  info "  - From TTY: login and Hyprland will auto-start"
  info "  - Or run: Hyprland"
  info ""
  info "First time setup:"
  info "  1. Place wallpaper at ~/wallpapers/default.jpg"
  info "  2. Log out and log back in to TTY"
  info "  3. Hyprland will start automatically"
}

setup_hyprland_autostart() {
  title "Configuring Hyprland auto-start"
  
  # Add to .zprofile for auto-start on TTY login
  local zprofile="$HOME/.zprofile"
  local autostart_marker="# Hyprland auto-start"
  
  if [[ -f "$zprofile" ]] && grep -q "$autostart_marker" "$zprofile"; then
    info "Hyprland auto-start already configured"
    return
  fi
  
  info "Adding Hyprland auto-start to .zprofile..."
  
  cat >> "$zprofile" << 'EOF'

# Hyprland auto-start
# Auto-start Hyprland on TTY login (not in SSH sessions)
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec Hyprland
fi
EOF
  
  success "Hyprland will auto-start on TTY1 login"
  info "You can disable this by editing ~/.zprofile"
} 