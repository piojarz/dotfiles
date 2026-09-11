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
  source "$(dirname "${BASH_SOURCE[0]}")/scripts/linux/arch.sh"
else
  error "Unsupported operating system (only macOS and Arch Linux are supported)"
fi

setup_dotfiles_path() {
  local actual_dotfiles
  actual_dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

  # Write path file so .zshenv can find dotfiles from any location
  mkdir -p "$config_dir"
  echo "$actual_dotfiles" > "$config_dir/dotfiles_path"

  # Create ~/dotfiles symlink if it doesn't already point here
  if [[ "$actual_dotfiles" != "$HOME/dotfiles" ]]; then
    if [[ -L "$HOME/dotfiles" ]]; then
      ln -sf "$actual_dotfiles" "$HOME/dotfiles"
      info "Updated ~/dotfiles symlink -> $actual_dotfiles"
    elif [[ ! -e "$HOME/dotfiles" ]]; then
      ln -s "$actual_dotfiles" "$HOME/dotfiles"
      info "Created ~/dotfiles symlink -> $actual_dotfiles"
    fi
  fi
}

# Main installation process
main() {
  local symlinks_only=false
  for arg in "$@"; do
    case "$arg" in
      --symlinks-only) symlinks_only=true ;;
      *) error "Unknown option: $arg" ;;
    esac
  done

  # Run pre-flight checks
  preflight_check

  # Clean up existing symlinks
  cleanup_symlinks

  # Create new symlinks
  setup_symlinks

  # Ensure ~/dotfiles symlink and ~/.config/dotfiles_path are in sync
  setup_dotfiles_path

  # --symlinks-only skips package installs/macOS defaults/git-user prompts,
  # for quickly re-linking config while iterating on dotfiles changes.
  if [[ "$symlinks_only" == true ]]; then
    success "Symlinks relinked!"
    return 0
  fi

  # Setup OS-specific configurations
  if is_macos; then
    setup_homebrew
    setup_macos_preferences
  else
    setup_arch
  fi

  # Setup shell
  setup_shell

  # Setup git user
  setup_git_user

  # Show backup summary if any backups were made
  show_backup_summary

  # Keep the backup directory from growing unbounded across repeated installs
  prune_old_backups

  success "Installation complete!"
}

# Run the installation
main "$@"