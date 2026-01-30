#!/usr/bin/env bash

# Script to install system-level dependencies for Hyprland
# Some packages need to be installed at the system level rather than through Home Manager

set -e

echo "================================================================"
echo "Installing system-level dependencies for Hyprland..."
echo "================================================================"

# Detect package manager
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "❌ Error: Unsupported package manager"
    echo "Please install the following packages manually:"
    echo "  - hyprland"
    echo "  - xdg-desktop-portal-hyprland"
    echo "  - polkit and a polkit authentication agent"
    echo "  - qt5-wayland, qt6-wayland"
    echo "  - pipewire, wireplumber"
    exit 1
fi

echo "Detected package manager: $PKG_MANAGER"
echo ""

# Arch Linux specific packages
if [[ "$PKG_MANAGER" == "pacman" ]]; then
    echo "Installing Arch Linux system packages..."
    
    # Core Hyprland packages
    $INSTALL_CMD \
        hyprland \
        xdg-desktop-portal-hyprland \
        qt5-wayland \
        qt6-wayland \
        glfw-wayland
    
    # Audio (PipeWire)
    $INSTALL_CMD \
        pipewire \
        wireplumber \
        pipewire-audio \
        pipewire-pulse \
        pipewire-alsa \
        pipewire-jack
    
    # Polkit
    $INSTALL_CMD \
        polkit \
        lxqt-policykit
    
    # Graphics drivers (optional but recommended)
    echo ""
    echo "Graphics driver installation (optional):"
    echo "  For NVIDIA: sudo pacman -S nvidia nvidia-utils nvidia-settings"
    echo "  For AMD: sudo pacman -S mesa vulkan-radeon libva-mesa-driver"
    echo "  For Intel: sudo pacman -S mesa vulkan-intel intel-media-driver"
    echo ""
    
    read -p "Do you want to install graphics drivers now? (nvidia/amd/intel/skip): " GPU_CHOICE
    
    case "$GPU_CHOICE" in
        nvidia)
            $INSTALL_CMD nvidia nvidia-utils nvidia-settings
            echo "✓ NVIDIA drivers installed"
            ;;
        amd)
            $INSTALL_CMD mesa vulkan-radeon libva-mesa-driver
            echo "✓ AMD drivers installed"
            ;;
        intel)
            $INSTALL_CMD mesa vulkan-intel intel-media-driver
            echo "✓ Intel drivers installed"
            ;;
        *)
            echo "Skipping graphics drivers"
            ;;
    esac
    
    # Enable PipeWire services
    echo ""
    echo "Enabling PipeWire services..."
    systemctl --user enable --now pipewire.service
    systemctl --user enable --now pipewire-pulse.service
    systemctl --user enable --now wireplumber.service
    
    # Enable services required by Noctalia (if available)
    echo ""
    echo "Enabling Noctalia-required system services..."
    
    # NetworkManager (for wifi support)
    if systemctl list-unit-files | grep -q "NetworkManager.service"; then
        sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
        info "NetworkManager enabled"
    fi
    
    # Bluetooth (for bluetooth support)
    if systemctl list-unit-files | grep -q "bluetooth.service"; then
        sudo systemctl enable --now bluetooth.service 2>/dev/null || true
        info "Bluetooth service enabled"
    fi
    
    # Power Profiles Daemon (for power-profile support)
    if systemctl list-unit-files | grep -q "power-profiles-daemon.service"; then
        sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
        info "Power Profiles Daemon enabled"
    fi
    
    # UPower (for battery support)
    if systemctl list-unit-files | grep -q "upower.service"; then
        sudo systemctl enable --now upower.service 2>/dev/null || true
        info "UPower enabled"
    fi
    
    echo "✓ System dependencies installed successfully"

# Ubuntu/Debian specific
elif [[ "$PKG_MANAGER" == "apt" ]]; then
    echo "Installing Ubuntu/Debian system packages..."
    
    sudo apt update
    
    # Note: Hyprland might not be available in standard repos
    # You may need to build from source or use a PPA
    
    $INSTALL_CMD \
        pipewire \
        wireplumber \
        pipewire-audio \
        libpipewire-0.3-0 \
        libpipewire-0.3-modules \
        pipewire-pulse
    
    echo "⚠️  Hyprland may need to be installed manually on Ubuntu/Debian"
    echo "See: https://hyprland.org"
    
# Fedora specific
elif [[ "$PKG_MANAGER" == "dnf" ]]; then
    echo "Installing Fedora system packages..."
    
    $INSTALL_CMD \
        hyprland \
        xdg-desktop-portal-hyprland \
        pipewire \
        wireplumber \
        pipewire-pulseaudio
    
    echo "✓ System dependencies installed successfully"
fi

echo ""
echo "================================================================"
echo "System dependencies installation complete!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "1. Log out and log back in (or reboot)"
echo "2. Run your dotfiles setup script to install user-level packages"
echo "3. Start Hyprland from a TTY with: Hyprland"
echo "   Or select it from your display manager"
echo ""
