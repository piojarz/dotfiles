#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# Get the directory where this script is located, then go up two levels to dotfiles root
# (scripts/common/ -> scripts/ -> dotfiles root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$(dirname "$SCRIPT_DIR")")"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

# Define linkable files
linkables=(
    "config/common/tmux/.tmux.conf"
    "config/common/zsh/.zshrc"
    "config/common/zsh/.zshenv"
    "config/common/zsh/.zstyles"
)

# Single files linked to an explicit absolute target, for tools that don't live
# under $XDG_CONFIG_HOME. Format: "<path relative to dotfiles>:<absolute target>".
# Only the file is linked, never the parent dir — a Claude Code config dir also
# holds its own state (projects/, plans/, history) which must stay out of git.
# Both profiles get the same file: the sandbox rules are machine-wide safety
# settings, not account-specific. See .zshrc claude-pj / claude-cd aliases,
# which set CLAUDE_CONFIG_DIR and so bypass ~/.claude entirely.
explicit_files=(
    "config/common/claude/settings.json:$HOME/.claude-cd/settings.json"
    "config/common/claude/settings.json:$HOME/.claude-pj/settings.json"
    "config/common/herdr/config.toml:$HOME/.config/herdr/config.toml"
)

# config/common dirs to skip in the generic "symlink the whole directory"
# loop below, because the tool writes its own runtime state (logs, sockets,
# session files) into the same directory -- only specific files inside are
# linked, via explicit_files above.
directory_excludes=(
    "herdr"
)

is_directory_excluded() {
  local name=$1
  for excl in "${directory_excludes[@]}"; do
    [[ "$name" == "$excl" ]] && return 0
  done
  return 1
}

cleanup_symlinks() {
  title "Cleaning up symlinks"
  
  # Clean up home directory symlinks
  for file in "${linkables[@]}"; do
    target="$HOME/$(basename "$file")"
    cleanup_symlink "$target"
  done

  # Clean up explicit-target file symlinks
  for entry in "${explicit_files[@]}"; do
    cleanup_symlink "${entry#*:}"
  done

  # Clean up config directory symlinks
  echo -e
  info "installing to $config_home"
  config_files=$(find "$DOTFILES/config" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    name="$(basename "$config")"
    is_directory_excluded "$name" && continue
    target="$config_home/$name"
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

  # Clean up Linux specific symlinks
  if ! is_macos; then
    linux_config_files=$(find "$DOTFILES/config/linux" -maxdepth 1 2>/dev/null)
    for config in $linux_config_files; do
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

  # Create explicit-target file symlinks
  for entry in "${explicit_files[@]}"; do
    target="${entry#*:}"
    ensure_directory "$(dirname "$target")"
    create_symlink "$DOTFILES/${entry%%:*}" "$target"
  done

  # Create config directory symlinks
  echo -e
  info "installing to $config_home"
  ensure_directory "$config_home"
  ensure_directory "$data_home"

  config_files=$(find "$DOTFILES/config/common" -maxdepth 1 2>/dev/null)
  for config in $config_files; do
    name="$(basename "$config")"
    is_directory_excluded "$name" && continue
    target="$config_home/$name"
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

  # Create Linux specific symlinks
  if ! is_macos; then
    linux_config_files=$(find "$DOTFILES/config/linux" -maxdepth 1 2>/dev/null)
    for config in $linux_config_files; do
      target="$config_home/$(basename "$config")"
      create_symlink "$config" "$target"
    done
  fi

} 