#!/usr/bin/env bash

# Colors for output
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_GRAY='\033[1;30m'
COLOR_NONE='\033[0m'

# Common utility functions
title() {
  echo -e "\n${COLOR_PURPLE}$1${COLOR_NONE}"
  echo -e "${COLOR_GRAY}==============================${COLOR_NONE}\n"
}

error() {
  echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
  exit 1
}

warning() {
  echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
  echo -e "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
  echo -e "${COLOR_GREEN}$1${COLOR_NONE}"
}

# Symlink management
create_symlink() {
  local source=$1
  local target=$2
  if [ -e "$target" ]; then
    if [ -L "$target" ]; then
      info "~${target#"$HOME"} is already a symlink... Skipping."
    else
      # Backup existing file/directory before replacing
      backup_if_exists "$target"
      info "Removing existing file and creating symlink for $source"
      rm -rf "$target"
      ln -s "$source" "$target"
    fi
  else
    info "Creating symlink for $source"
    ln -s "$source" "$target"
  fi
}

cleanup_symlink() {
  local target=$1
  if [ -L "$target" ]; then
    info "Cleaning up \"$target\""
    rm "$target"
  elif [ -e "$target" ]; then
    warning "Skipping \"$target\" because it is not a symlink"
  else
    warning "Skipping \"$target\" because it does not exist"
  fi
}

# Directory management
ensure_directory() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    info "Creating $dir"
    mkdir -p "$dir"
  fi
}

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Backup management
backup_file() {
  local file=$1
  if [ -e "$file" ] && [ ! -L "$file" ]; then
    ensure_directory "$BACKUP_DIR"
    local backup_path="$BACKUP_DIR/$(basename "$file")"
    info "Backing up existing file: $file -> $backup_path"
    cp -r "$file" "$backup_path"
  fi
}

backup_if_exists() {
  local target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    backup_file "$target"
  fi
}

# Package installation helpers
install_package() {
  local package_manager=$1
  shift
  local packages=("$@")
  
  if [[ ${#packages[@]} -eq 0 ]]; then
    error "No packages specified"
    return 1
  fi
  
  info "Installing: ${packages[*]}"
  case $package_manager in
    "pacman")
      sudo pacman -S --noconfirm "${packages[@]}"
      ;;
    "brew")
      for package in "${packages[@]}"; do
        brew install "$package"
      done
      ;;
    *)
      error "Unsupported package manager: $package_manager"
      ;;
  esac
}

# OS detection
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

is_arch() {
  [ -f /etc/arch-release ]
}

# Show backup summary
show_backup_summary() {
  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    title "Backup Summary"
    info "Your existing configurations have been backed up to:"
    success "$BACKUP_DIR"
    info "Backed up files:"
    ls -la "$BACKUP_DIR"
  fi
}

 