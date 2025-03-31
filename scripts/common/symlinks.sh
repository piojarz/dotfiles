#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DOTFILES="$(pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

# Define linkable files
linkables=(
    "config/common/zsh/.zshrc"
    "config/common/zsh/.zshenv"
    "config/common/zsh/.zstyles"
)

cleanup_symlinks() {
  title "Cleaning up symlinks"
  
  # Clean up home directory symlinks
  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    cleanup_symlink "$target"
  done

  # Clean up config directory symlinks
  echo -e
  info "installing to $config_home"
  config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    cleanup_symlink "$target"
  done

  # Clean up macOS specific symlinks
  if is_macos; then
    mac_config_files=$(find "$DOTFILES/config/macos" -maxdepth 1 2>/dev/null)
    for config in $mac_config_files; do
      target="$config_home/$(basename "$config")"
      cleanup_symlink "$target"
    done
  fi
}

setup_symlinks() {
  title "Creating symlinks"

  # Create home directory symlinks
  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    create_symlink "$DOTFILES/$file" "$target"
  done

  # Create config directory symlinks
  echo -e
  info "installing to $config_home"
  ensure_directory "$config_home"
  ensure_directory "$data_home"

  config_files=$(find "$DOTFILES/config/common" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    target="$config_home/$(basename "$config")"
    create_symlink "$config" "$target"
  done

  # Create macOS specific symlinks
  if is_macos; then
    mac_config_files=$(find "$DOTFILES/config/macos" -maxdepth 1 2>/dev/null)
    for config in $mac_config_files; do
      target="$config_home/$(basename "$config")"
      create_symlink "$config" "$target"
    done
  fi

  # Create .zshenv symlink
  if [ ! -e "$HOME/.zshenv" ]; then
    create_symlink "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
  fi
} 