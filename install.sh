#!/usr/bin/env bash

set -euo pipefail

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/utils.sh"

# Source platform-specific scripts
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/symlinks.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/shell.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/git-setup.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/preflight.sh"

# Source OS-specific scripts
if is_macos; then
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/macos/setup.sh"
elif is_arch; then
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/linux/setup.sh"
else
  error "Unsupported operating system (only macOS and Arch Linux are supported)"
fi

# Main installation process
main() {
  # Run pre-flight checks
  preflight_check
  
  # Clean up existing symlinks
  cleanup_symlinks
  
  # Create new symlinks
  setup_symlinks

  # Setup OS-specific configurations
  if is_macos; then
    setup_homebrew
    setup_macos_preferences
  else
    setup_linux
  fi

  # Setup shell
  setup_shell

  # Setup git user
  setup_git_user

  # Show backup summary if any backups were made
  show_backup_summary

  success "Installation complete!"
}

# Run the installation
main