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
    info "~${target#"$HOME"} already exists... Skipping."
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

# Package installation helpers
install_package() {
  local package=$1
  local package_manager=$2
  info "Installing $package"
  case $package_manager in
    "apt")
      sudo apt-get install -y "$package"
      ;;
    "pacman")
      sudo pacman -S --noconfirm "$package"
      ;;
    "brew")
      brew install "$package"
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

is_ubuntu() {
  [ -f /etc/lsb-release ]
} 