#!/bin/bash

# Yabai + SKHD Installation Script
# Replaces AeroSpace with Yabai for macOS window management

set -e

echo "🚀 Installing Yabai and SKHD..."

# 1. Install via Homebrew
if ! command -v yabai &> /dev/null; then
    echo "📦 Installing yabai..."
    brew install koekeishiya/formulae/yabai
else
    echo "✅ yabai already installed"
fi

if ! command -v skhd &> /dev/null; then
    echo "📦 Installing skhd..."
    brew install koekeishiya/formulae/skhd
else
    echo "✅ skhd already installed"
fi

# 2. Create symlinks
echo "🔗 Setting up configuration files..."
rm -f ~/.yabairc ~/.skhdrc
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/yabairc ~/.yabairc
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/skhdrc ~/.skhdrc
chmod +x ~/.yabairc
chmod +x ~/.skhdrc

# 3. Start services
echo "▶️  Starting services..."
brew services start yabai
brew services start skhd

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Grant Accessibility permissions to:"
echo "      - /usr/local/bin/yabai"
echo "      - /usr/local/bin/skhd"
echo "   2. Grant Screen Recording permission to:"
echo "      - /usr/local/bin/yabai"
echo "   3. Reboot to ensure permissions take effect"
echo ""
echo "🔧 To reload configs:"
echo "   yabai --load-config"
echo "   skhd --reload"