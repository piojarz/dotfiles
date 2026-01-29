# Arch Linux Setup Options

This document explains the enhanced Arch Linux setup that now supports optional desktop environment installation.

## Usage

```bash
./setup.sh
```

## What Gets Installed

### Core Components
- Core development tools (git, neovim, docker, etc.)
- AUR helper (yay)
- Shell utilities (fzf, eza, bat, ripgrep, etc.)
- Fonts and terminal setup
- Productivity applications (VS Code, Slack, Spotify, etc.)

### Desktop Environment
- **Hyprland**: Wayland compositor with animations
- **Noctalia**: Modern desktop shell (Bar, Notifications, Dashboard)
- **SDDM**: Display manager for login
- **PipeWire**: Modern audio stack
- **Rofi**: Application launcher
- **Thunar**: File manager
- **Screenshot tools**: grim, slurp, swappy


## Post-Installation

### Basic Setup
1. Restart your shell: `source ~/.zshrc`
2. Start using your development tools

### Desktop Environment Setup
1. Reboot your system: `sudo reboot`
2. Select "Hyprland" in SDDM login screen
3. Key bindings:
   - `SUPER+RETURN` - Open terminal
   - `SUPER+D` - Application launcher
   - `SUPER+Q` - Close window
   - `SUPER+1-9` - Switch workspaces

## Configuration Files

All configurations are managed through the dotfiles system:

- `config/linux/` - Linux-specific configs (Hyprland, Waybar, etc.)
- `config/common/` - Cross-platform configs (alacritty, fish, nvim, etc.)

## Troubleshooting

### Desktop Environment Issues
- Ensure graphics drivers are installed
- Check SDDM service: `systemctl status sddm`
- Check PipeWire services: `systemctl --user status pipewire`

### Package Issues
- Update system: `sudo pacman -Syu`
- Clean AUR cache: `yay -Scc`

### Configuration Not Applied
- Run symlinks manually: `./scripts/common/symlinks.sh`
- Check for broken symlinks: `find -L ~/.config -type l`

## Migration from Old Setup

If you previously used the separate `hyprland_setup.sh` script:

1. Your existing configurations will be preserved
2. New configurations will be linked from dotfiles
3. Manual migration may be needed for custom settings

## Customization

### Modify Package Lists
Edit `scripts/linux/system-setup.sh` and `scripts/linux/desktop-services.sh` to add/remove packages.

### Customize Desktop Environment
Configuration files are in:
- `config/linux/hypr/` - Hyprland settings
- `modules/linux/home/desktop/noctalia.nix` - Noctalia HM settings

### Add New Applications
1. Install package via pacman or yay
2. Add to appropriate package array in setup script
3. Create configuration if needed in `config/` directory