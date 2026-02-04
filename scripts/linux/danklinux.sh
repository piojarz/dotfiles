#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../common/utils.sh"

setup_danklinux() {
  title "Installing Danklinux Shell"
  
  if command -v dank &> /dev/null; then
    info "Danklinux is already installed. Skipping."
    return
  fi

  info "Running Danklinux installation script..."
  curl -fsSL https://install.danklinux.com | sh
  
  success "Danklinux installation complete!"
}

setup_danklinux
