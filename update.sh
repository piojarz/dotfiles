#!/usr/bin/env bash

# Dotfiles Update Script
# Updates configurations, plugins, and tools without full reinstallation

set -e

# Source common utilities
source "$(dirname "${BASH_SOURCE[0]}")/scripts/common/utils.sh"

title "Updating Dotfiles"

# Pull latest changes from git
info "Pulling latest changes from git..."
git pull origin $(git branch --show-current)

# Update git submodules if any
if [ -f .gitmodules ]; then
  info "Updating git submodules..."
  git submodule update --init --recursive
  git submodule update --remote
fi

# Update zsh plugins via antidote
info "Updating zsh plugins..."
if command -v antidote &> /dev/null; then
  antidote update
elif [ -d "${ZDOTDIR:-$HOME/.config/zsh}/.antidote" ]; then
  # Try to source antidote and update
  if [ -f "$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" ]; then
    source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
    antidote update
  elif [ -f "/usr/share/antidote/antidote.zsh" ]; then
    source /usr/share/antidote/antidote.zsh
    antidote update
  fi
fi

# Update Homebrew packages (macOS)
if is_macos && command -v brew &> /dev/null; then
  info "Updating Homebrew packages..."
  brew update
  brew upgrade
  brew bundle --force
  brew cleanup
fi

# Update Arch packages
if is_arch && command -v yay &> /dev/null; then
  info "Updating Arch packages..."
  yay -Syu --noconfirm
fi

# Update TPM plugins (Tmux)
if [ -d "$HOME/.config/tmux/plugins/tpm" ]; then
  info "Updating Tmux plugins..."
  "$HOME/.config/tmux/plugins/tpm/bin/update_plugins" all || true
fi

# Update fnm (Fast Node Manager)
if command -v fnm &> /dev/null; then
  info "Updating fnm..."
  fnm install --lts
  fnm use lts-latest
fi

# Reload shell configuration
info "Reloading shell configuration..."
if [ -n "$ZSH_VERSION" ]; then
  # Already in zsh, just source
  source "$HOME/.zshrc"
elif command -v zsh &> /dev/null; then
  info "Please restart your terminal or run: source ~/.zshrc"
fi

# Update kanata configuration
info "Checking kanata configuration..."
if command -v kanata &> /dev/null; then
  # Test kanata config is valid
  if kanata --check --cfg "$HOME/.config/kanata/kanata.kbd" 2>/dev/null; then
    success "Kanata configuration is valid"
  else
    warning "Kanata configuration may have issues. Please check: ~/.config/kanata/kanata.kbd"
  fi
fi

# Update completion databases
info "Updating completion databases..."
if command -v zsh &> /dev/null; then
  # Remove old completion dump to force regeneration
  rm -f "${ZDOTDIR:-$HOME/.config/zsh}/.zcompdump"* 2>/dev/null || true
fi

success "Dotfiles update complete!"
info "Please restart your terminal to ensure all changes take effect."

# Show next steps
if is_macos; then
  info "Next steps:"
  info "  - If kanata was updated, restart the service: launchctl unload ~/Library/LaunchAgents/com.kanata.kanata.plist && launchctl load ~/Library/LaunchAgents/com.kanata.kanata.plist"
fi
