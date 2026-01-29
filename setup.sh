#!/bin/bash

# Unified setup script for Nix Home Manager dotfiles
# Handles Git identity, user detection, and platform-specific services

set -e

# Colors for output
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_NONE='\033[0m'
COLOR_GRAY='\033[0;90m'

title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

info() {
  echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

# Source local config if it exists
if [[ -f ".local_config" ]]; then
  source ".local_config"
fi

# Prompt for Git identity if not set
configure_git_identity() {
  title "Configuring Git Identity"
  
  if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]]; then
    info "Setting up your Git identity..."
    
    local default_name=$(git config --get user.name || echo "")
    local default_email=$(git config --get user.email || echo "")
    
    echo -n -e "${COLOR_YELLOW}Enter your Git name [$default_name]: ${COLOR_NONE}"
    read input_name
    export GIT_NAME=${input_name:-$default_name}
    
    echo -n -e "${COLOR_YELLOW}Enter your Git email [$default_email]: ${COLOR_NONE}"
    read input_email
    export GIT_EMAIL=${input_email:-$default_email}
    
    # Save for future runs
    cat > .local_config << EOF
export GIT_NAME="$GIT_NAME"
export GIT_EMAIL="$GIT_EMAIL"
EOF
    success "Git identity saved to .local_config"
  else
    info "Git identity loaded from .local_config: $GIT_NAME <$GIT_EMAIL>"
  fi
}

# Run platform-specific system setup that Nix doesn't handle (yet)
run_platform_setup() {
  title "Running Platform-Specific System Setup"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local macos_setup="scripts/macos/setup.sh"
    if [[ -f "$macos_setup" ]]; then
      info "Executing macOS system setup (Homebrew & Preferences)..."
      (
        source "$(dirname "$0")/scripts/common/utils.sh"
        source "$macos_setup"
        setup_homebrew
        setup_macos_preferences
      )
    else
      warning "macOS setup script not found at $macos_setup"
    fi
  elif [[ -f /etc/arch-release ]]; then
    local linux_setup="scripts/linux/system-setup.sh"
    local desktop_setup="scripts/linux/desktop-services.sh"
    
    if [[ -f "$linux_setup" ]]; then
      info "Executing Arch Linux system setup (Services & AUR)..."
      bash "$linux_setup"
    fi
    
    if [[ -f "$desktop_setup" ]]; then
      info "Executing Linux desktop services setup..."
      bash "$desktop_setup"
    fi
  fi
}

# Nix-based setup
run_nix_setup() {
  title "Running Nix Home Manager Setup"
  
  export USER=${USER:-$(whoami)}
  
  info "Setup variables:"
  info "  User: ${USER}"
  info "  Git Name: ${GIT_NAME}"
  info "  Git Email: ${GIT_EMAIL}"
  echo ""
  
  info "Building Home Manager configuration..."
  
  # Determine host configuration based on OS
  local host_config=""
  if [[ "$OSTYPE" == "darwin"* ]]; then
    host_config="macos-laptop"
  elif [[ -f /etc/arch-release ]]; then
    host_config="linux-desktop"
  else
    host_config="common-workstation"
  fi

  info "Selected host configuration: ${host_config}"
  
  # Determine Home Manager command (use nix run for bootstrap)
  local switch_cmd=(home-manager switch)
  if ! command -v home-manager >/dev/null 2>&1; then
    info "Home Manager not found in PATH, using 'nix run' for initial bootstrap..."
    switch_cmd=(nix run --extra-experimental-features "nix-command flakes" github:nix-community/home-manager -- switch)
  fi

  # Use --impure to allow reading environment variables
  if "${switch_cmd[@]}" --flake .#${host_config} --impure --extra-experimental-features "nix-command flakes"; then
    success "Nix Home Manager setup completed!"
    run_platform_setup
  else
    warning "Home Manager setup failed."
    return 1
  fi
}

# Ensure Nix is installed
ensure_nix() {
  if ! command -v nix >/dev/null 2>&1; then
    title "Installing Nix"
    info "Nix not found. Installing via official multi-user script..."
    
    # Run the official installer
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    
    # Source nix for the current session
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    success "Nix installed successfully! You might need to restart your terminal if 'nix' command is not found."
  else
    info "Nix is already installed."
  fi
}

# Ensure Nix experimental features are enabled
ensure_nix_experimental_features() {
  local nix_conf_dir="$HOME/.config/nix"
  local nix_conf="$nix_conf_dir/nix.conf"
  
  if [[ ! -d "$nix_conf_dir" ]]; then
    mkdir -p "$nix_conf_dir"
  fi
  
  if [[ ! -f "$nix_conf" ]]; then
    info "Creating $nix_conf to enable experimental features..."
    echo "experimental-features = nix-command flakes" > "$nix_conf"
  elif ! grep -q "experimental-features" "$nix_conf"; then
    info "Enabling Nix experimental features in $nix_conf..."
    echo "experimental-features = nix-command flakes" >> "$nix_conf"
  elif ! grep -q "nix-command" "$nix_conf" || ! grep -q "flakes" "$nix_conf"; then
    info "Ensuring 'nix-command' and 'flakes' are in experimental-features..."
    # Add to existing experimental-features line
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/^experimental-features = \(.*\)/experimental-features = \1 nix-command flakes/' "$nix_conf"
    else
      sed -i 's/^experimental-features = \(.*\)/experimental-features = \1 nix-command flakes/' "$nix_conf"
    fi
  fi
}

# Ensure Home Manager is available
ensure_home_manager() {
  title "Checking Home Manager"
  
  # Check if home-manager is installed via nix profile (which conflicts with HM-managed profiles)
  if nix profile list --extra-experimental-features "nix-command flakes" 2>/dev/null | grep -q "home-manager"; then
    info "Detected 'home-manager' in nix profile. Removing to prevent conflicts with activation..."
    nix profile remove home-manager --extra-experimental-features "nix-command flakes" || true
  fi

  if ! command -v home-manager >/dev/null 2>&1; then
    info "Home Manager not installed. Will use 'nix run' for the initial bootstrap."
  else
    info "Home Manager is already available."
  fi
}

# Main function
main() {
  title "Dotfiles Setup"
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo "Options: --help"
        exit 0
        ;;
      *) warning "Unknown option: $1"; exit 1 ;;
    esac
  done
  
  ensure_nix
  ensure_nix_experimental_features
  ensure_home_manager

  configure_git_identity
  run_nix_setup
  
  success "Setup completed successfully!"
}

# Run main function
main "$@"