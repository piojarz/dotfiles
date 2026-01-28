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
    
    if [[ "${SETUP_DESKTOP:-false}" == "true" && -f "$desktop_setup" ]]; then
      info "Executing Linux desktop services setup..."
      bash "$desktop_setup"
    fi
  fi
}

# Nix-based setup
run_nix_setup() {
  title "Running Nix Home Manager Setup"
  
  # Export environment variables for Nix
  if [[ -z "$SETUP_DESKTOP" ]]; then
    if [[ -f /etc/arch-release ]]; then
      export SETUP_DESKTOP=true
    else
      export SETUP_DESKTOP=false
    fi
  fi
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
  
  # Use --impure to allow reading environment variables
  if home-manager switch --flake .#${host_config} --impure; then
    success "Nix Home Manager setup completed!"
    run_platform_setup
  else
    warning "Home Manager setup failed."
    return 1
  fi
}

# Main function
main() {
  title "Dotfiles Setup"
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      --desktop) export SETUP_DESKTOP=true; shift ;;
      --no-desktop) export SETUP_DESKTOP=false; shift ;;
      --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo "Options: --desktop, --no-desktop, --help"
        exit 0
        ;;
      *) warning "Unknown option: $1"; exit 1 ;;
    esac
  done
  
  if ! command -v home-manager >/dev/null 2>&1; then
    warning "home-manager not found. Please install Nix and Home Manager first."
    exit 1
  fi

  configure_git_identity
  run_nix_setup
  
  success "Setup completed successfully!"
}

# Run main function
main "$@"