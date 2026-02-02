#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_noctalia_shell() {
  title "Setting up Noctalia Shell"

  # Install noctalia-shell from AUR
  if ! command -v qs &>/dev/null; then
    info "Installing noctalia-shell from AUR..."
    yay -S --noconfirm noctalia-shell
  else
    info "Noctalia Shell (qs) already installed, skipping installation..."
  fi

  # Detect compositor and configure accordingly
  local compositor=$(detect_compositor)

  case "$compositor" in
  "hyprland")
    setup_noctalia_hyprland
    ;;
  "niri")
    setup_noctalia_niri
    ;;
  "unknown")
    warning "Could not detect compositor. Please manually configure noctalia-shell."
    info "For Hyprland: add 'exec-once = qs -c noctalia-shell' to ~/.config/hypr/hyprland.conf"
    info "For Niri: add 'spawn-at-startup \"qs\" \"-c\" \"noctalia-shell\"' to ~/.config/niri/config.kdl"
    ;;
  esac

  # Optionally set up systemd service (advanced)
  setup_noctalia_systemd_service

  success "Noctalia Shell setup complete!"
  info "Note: You may need to log out and log back in for all changes to take effect"
}

detect_compositor() {
  # Check if Hyprland is installed
  if command -v Hyprland &>/dev/null; then
    echo "hyprland"
    return
  fi

  # Check if Niri is installed
  if command -v niri &>/dev/null; then
    echo "niri"
    return
  fi

  # Check currently running session
  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "hyprland"
    return
  fi

  if [ -n "$NIRI_SOCKET" ]; then
    echo "niri"
    return
  fi

  echo "unknown"
}

setup_noctalia_hyprland() {
  info "Configuring Noctalia Shell for Hyprland..."

  local hypr_config="$HOME/.config/hypr/hyprland.conf"
  local marker="# Noctalia Shell autostart"

  # Check if already configured
  if [ -f "$hypr_config" ] && grep -q "$marker" "$hypr_config"; then
    info "Noctalia Shell already configured in Hyprland config"
    return
  fi

  # Add noctalia-shell autostart to Hyprland config
  if [ -f "$hypr_config" ]; then
    info "Adding Noctalia Shell to Hyprland autostart..."
    cat >>"$hypr_config" <<EOF

$marker
# Noctalia shell - modern QtQuick-based shell for Wayland
exec-once = qs -c noctalia-shell
EOF
    success "Added Noctalia Shell to Hyprland autostart"
  else
    warning "Hyprland config not found at $hypr_config"
    info "To manually configure, add this line to your hyprland.conf:"
    info "  exec-once = qs -c noctalia-shell"
  fi
}

setup_noctalia_niri() {
  info "Configuring Noctalia Shell for Niri..."

  local niri_config="$HOME/.config/niri/config.kdl"
  local marker="// Noctalia Shell autostart"

  # Check if already configured
  if [ -f "$niri_config" ] && grep -q "$marker" "$niri_config"; then
    info "Noctalia Shell already configured in Niri config"
    return
  fi

  # Add noctalia-shell autostart to Niri config
  if [ -f "$niri_config" ]; then
    info "Adding Noctalia Shell to Niri autostart..."
    cat >>"$niri_config" <<EOF

$marker
// Noctalia shell - modern QtQuick-based shell for Wayland
spawn-at-startup "qs" "-c" "noctalia-shell"
EOF
    success "Added Noctalia Shell to Niri autostart"
  else
    warning "Niri config not found at $niri_config"
    info "To manually configure, add this line to your config.kdl:"
    info "  spawn-at-startup \"qs\" \"-c\" \"noctalia-shell\""
  fi
}

setup_noctalia_systemd_service() {
  local systemd_user_dir="$HOME/.config/systemd/user"
  local service_file="$systemd_user_dir/noctalia.service"

  # Check if service file already exists (AUR package may have created it)
  if [ -f "$service_file" ]; then
    info "Noctalia systemd service already exists"
    return
  fi

  info "Creating Noctalia systemd user service..."

  ensure_directory "$systemd_user_dir"

  # Determine compositor target
  local compositor_target="graphical-session.target"
  local compositor=$(detect_compositor)

  case "$compositor" in
  "hyprland")
    # For Hyprland, we need a custom target or use graphical-session
    info "Note: For Hyprland, you may want to bind to a custom target"
    info "See: https://docs.noctalia.dev/getting-started/running-the-shell/"
    ;;
  "niri")
    compositor_target="niri.service"
    ;;
  esac

  cat >"$service_file" <<EOF
[Unit]
Description=Noctalia Shell Service
PartOf=graphical-session.target
Requisite=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=qs -c noctalia-shell
Restart=on-failure
RestartSec=1

[Install]
WantedBy=graphical-session.target
EOF

  systemctl --user daemon-reload

  success "Noctalia systemd service created at $service_file"
  info "To enable the service: systemctl --user enable noctalia.service"
  info "To start now: systemctl --user start noctalia.service"

  # For Niri, offer to bind directly
  if [ "$compositor" = "niri" ]; then
    info "For Niri integration, run: systemctl --user add-wants niri.service noctalia.service"
  fi
}

# Run setup if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  setup_noctalia_shell
fi
