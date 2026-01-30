#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

setup_git_user() {
  title "Configuring Git User"
  
  local git_name=""
  local git_email=""
  local current_name
  local current_email
  
  # Check if already configured
  current_name=$(git config --global user.name 2>/dev/null || echo "")
  current_email=$(git config --global user.email 2>/dev/null || echo "")
  
  if [[ -n "$current_name" && -n "$current_email" ]]; then
    info "Git is already configured:"
    info "  Name:  $current_name"
    info "  Email: $current_email"
    
    read -p "Do you want to change these settings? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      info "Keeping existing git configuration."
      setup_git_defaults
      return 0
    fi
  fi
  
  # Prompt for user name
  if [[ -z "$current_name" ]]; then
    echo -n "Enter your full name for git commits: "
  else
    echo -n "Enter your full name for git commits [$current_name]: "
  fi
  read git_name
  
  # Use existing if blank
  if [[ -z "$git_name" && -n "$current_name" ]]; then
    git_name="$current_name"
  fi
  
  # Prompt for email
  if [[ -z "$current_email" ]]; then
    echo -n "Enter your email address for git commits: "
  else
    echo -n "Enter your email address for git commits [$current_email]: "
  fi
  read git_email
  
  # Use existing if blank
  if [[ -z "$git_email" && -n "$current_email" ]]; then
    git_email="$current_email"
  fi
  
  # Validate inputs
  if [[ -z "$git_name" ]]; then
    warning "No name provided, skipping git user configuration."
    return 1
  fi
  
  if [[ -z "$git_email" ]]; then
    warning "No email provided, skipping git user configuration."
    return 1
  fi
  
  # Configure git
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  
  success "Git user configured:"
  success "  Name:  $git_name"
  success "  Email: $git_email"
  
  # Check if git config file needs to be linked
  if [[ ! -e "$HOME/.gitconfig" ]]; then
    warning "Git config file not found at ~/.gitconfig"
    info "Make sure to run ./install.sh to link the dotfiles git config"
  fi
  
  # Setup additional git defaults
  setup_git_defaults
  
  # Optional: GPG signing setup
  read -p "Do you want to set up GPG signing for git commits? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    setup_git_signing
  fi
}

setup_git_defaults() {
  info "Configuring default git settings..."
  
  # Check if git config file is already symlinked
  local git_config_linked=""
  if [[ -L "$HOME/.gitconfig" ]]; then
    git_config_linked=$(readlink "$HOME/.gitconfig" 2>/dev/null || echo "")
  fi
  
  # Only set defaults that aren't in the config file
  if [[ ! "$git_config_linked" == *"dotfiles"* ]] && [[ ! -f "$HOME/.gitconfig" ]]; then
    # No gitconfig linked, set basic defaults
    info "No git config file detected, setting basic defaults..."
    
    # Default branch name
    git config --global init.defaultBranch main
    
    # Pull behavior
    git config --global pull.rebase false
    
    # Push behavior
    git config --global push.default simple
    
    # Better diffs with delta (if installed)
    if command -v delta &> /dev/null; then
      git config --global core.pager delta
      git config --global interactive.diffFilter "delta --color-only"
    fi
    
    # Basic aliases (only if no config file)
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.lga "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    
    # Color settings
    git config --global color.ui auto
    
    # Rebase settings
    git config --global rebase.autoSquash true
    git config --global rebase.autoStash true
    
    success "Basic git defaults configured!"
  else
    info "Git config file already linked, skipping basic defaults (they're in the config file)"
    
    # Even with config file, ensure delta is properly configured if installed
    if command -v delta &> /dev/null; then
      # Only set pager if not already set to delta
      local current_pager=$(git config --global core.pager 2>/dev/null || echo "")
      if [[ "$current_pager" != "delta" ]]; then
        info "Setting delta as git pager..."
        git config --global core.pager delta
      fi
      
      # Set interactive diff filter if not already set
      local current_filter=$(git config --global interactive.diffFilter 2>/dev/null || echo "")
      if [[ -z "$current_filter" ]]; then
        git config --global interactive.diffFilter "delta --color-only"
      fi
    fi
  fi
  
  success "Git defaults configured!"
}

setup_git_signing() {
  info "Setting up GPG signing for git commits..."
  
  # Check if GPG is available
  if ! command -v gpg &> /dev/null; then
    warning "GPG is not installed. Skipping signing setup."
    info "Install gpg and re-run this script if you want signing."
    return 1
  fi
  
  # List existing keys
  local keys
  keys=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep sec | awk '{print $2}' | cut -d'/' -f2)
  
  if [[ -n "$keys" ]]; then
    info "Existing GPG keys found:"
    echo "$keys"
    echo
    read -p "Enter the key ID to use for signing (or press Enter to skip): " key_id
    
    if [[ -n "$key_id" ]]; then
      git config --global user.signingkey "$key_id"
      git config --global commit.gpgSign true
      git config --global tag.gpgSign true
      success "GPG signing configured with key: $key_id"
      info "Don't forget to add your GPG key to GitHub/GitLab!"
    fi
  else
    info "No GPG keys found."
    read -p "Would you like to generate a new GPG key? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      gpg --full-generate-key
      # Re-run to select the new key
      setup_git_signing
    fi
  fi
}
