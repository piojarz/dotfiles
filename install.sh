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
else
  error "Unsupported operating system (only macOS and Arch Linux are supported)"
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
    setup_arch
  fi

  # Setup shell
  setup_shell

  # Show backup summary if any backups were made
  show_backup_summary

  success "Installation complete!"
}

# Run the installation
main