#!/usr/bin/env bash

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/utils.sh"

# Source platform-specific scripts
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/symlinks.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/shell.sh"

# Source OS-specific scripts
if is_macos; then
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/macos/setup.sh"
elif is_arch; then
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/linux/arch.sh"
elif is_ubuntu; then
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/linux/ubuntu.sh"
else
  error "Unsupported operating system"
fi

# Main installation process
main() {
  # Clean up existing symlinks
  cleanup_symlinks
  
  # Create new symlinks
  setup_symlinks

  # Setup OS-specific configurations
  if is_macos; then
    setup_homebrew
    setup_macos_preferences
  else
    if is_arch; then
      setup_arch
    else
      setup_ubuntu
    fi
  fi

  # Setup shell
  setup_shell

  success "Installation complete!"
}

# Run the installation
main