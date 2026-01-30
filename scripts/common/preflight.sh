#!/usr/bin/env bash

# Pre-flight checks for dotfiles installation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

preflight_check() {
  title "Running pre-flight checks"
  
  local errors=0
  
  # Check if git is installed
  if ! command -v git &> /dev/null; then
    error "git is not installed. Please install git first."
    ((errors++))
  else
    success "git is installed"
  fi
  
  # Check if we're in a git repository
  if [[ ! -d "$DOTFILES/.git" ]]; then
    error "Dotfiles directory is not a git repository: $DOTFILES"
    info "Please clone the dotfiles repository first:"
    info "  git clone https://github.com/yourusername/dotfiles.git ~/dotfiles"
    ((errors++))
  else
    success "Dotfiles git repository found"
  fi
  
  # Check for sudo access (needed for some operations)
  if ! sudo -n true 2>/dev/null; then
    warning "No active sudo session detected. Some operations may prompt for password."
  else
    success "Sudo access available"
  fi
  
  # Platform-specific checks
  if is_macos; then
    preflight_macos
  elif is_arch; then
    preflight_arch
  else
    error "Unsupported operating system"
    ((errors++))
  fi
  
  # Check disk space (need at least 1GB free)
  local free_space
  free_space=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/Gi//')
  if [[ -n "$free_space" ]] && (( $(echo "$free_space < 1" | bc -l 2>/dev/null || echo "0") )); then
    warning "Low disk space: ${free_space}GB available. Recommend at least 1GB."
  else
    success "Sufficient disk space available"
  fi
  
  if [[ $errors -gt 0 ]]; then
    error "Pre-flight checks failed with $errors error(s). Please fix the issues above and try again."
    exit 1
  fi
  
  success "All pre-flight checks passed!"
}

preflight_macos() {
  info "Checking macOS prerequisites..."
  
  # Check macOS version (need at least 11.0)
  local macos_version
  macos_version=$(sw_vers -productVersion)
  if [[ "$(echo -e "11.0\n$macos_version" | sort -V | head -n1)" != "11.0" ]]; then
    warning "macOS version $macos_version detected. Recommended: 11.0 (Big Sur) or later."
  else
    success "macOS version $macos_version is supported"
  fi
}

preflight_arch() {
  info "Checking Arch Linux prerequisites..."
  
  # Check if base-devel is installed
  if ! pacman -Q base-devel &> /dev/null; then
    warning "base-devel package group not detected. It will be installed during setup."
  else
    success "base-devel is installed"
  fi
  
  # Check for internet connectivity
  if ! ping -c 1 archlinux.org &> /dev/null; then
    warning "Internet connectivity check failed. Installation requires internet access."
  else
    success "Internet connectivity confirmed"
  fi
}
