#!/usr/bin/env bash

# Script to set up Hyprland session entry for display managers

set -e

echo "================================================================"
echo "Setting up Hyprland session..."
echo "================================================================"

# Check if we're on a system with systemd
if ! command -v systemctl &> /dev/null; then
    echo "❌ Error: This script requires systemd"
    exit 1
fi

# Create Wayland session directory if it doesn't exist
sudo mkdir -p /usr/share/wayland-sessions

# Create Hyprland desktop entry
echo "Creating Hyprland session file..."
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

echo "✓ Hyprland session file created at /usr/share/wayland-sessions/hyprland.desktop"

# Create a simple wrapper script for starting Hyprland (optional)
WRAPPER_SCRIPT="$HOME/.local/bin/start-hyprland"
mkdir -p "$(dirname "$WRAPPER_SCRIPT")"

cat > "$WRAPPER_SCRIPT" <<'EOF'
#!/usr/bin/env bash

# Hyprland startup wrapper
# This script sets up the environment and starts Hyprland

# Set XDG environment
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

# Enable Wayland for various toolkits
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# Hyprland-specific
export WLR_NO_HARDWARE_CURSORS=1

# NVIDIA-specific (uncomment if using NVIDIA)
# export LIBVA_DRIVER_NAME=nvidia
# export GBM_BACKEND=nvidia-drm
# export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Start Hyprland
exec Hyprland
EOF

chmod +x "$WRAPPER_SCRIPT"
echo "✓ Hyprland wrapper script created at $WRAPPER_SCRIPT"

echo ""
echo "================================================================"
echo "Hyprland session setup complete!"
echo "================================================================"
echo ""
echo "You can now:"
echo "  1. Start Hyprland from your display manager (GDM, SDDM, LightDM, etc.)"
echo "  2. Run 'Hyprland' from a TTY (Ctrl+Alt+F2)"
echo "  3. Use the wrapper: $WRAPPER_SCRIPT"
echo ""
echo "For display manager setup:"
echo "  - GDM: Already configured, just select Hyprland at login"
echo "  - SDDM: Already configured, select Hyprland from session menu"
echo "  - LightDM: Already configured, select Hyprland from session menu"
echo ""
