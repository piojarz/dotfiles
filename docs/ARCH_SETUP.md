# Arch Linux Setup Options

This document explains the enhanced Arch Linux setup that now supports optional desktop environment installation.

## Usage

### Basic Setup (Development Tools Only)
```bash
./install.sh
```

### Full Desktop Environment Setup
```bash
SETUP_DESKTOP=true ./install.sh
```

### Custom Setup Options
```bash
SETUP_DESKTOP=true SETUP_FISH=true SETUP_CHROMIUM=false ./install.sh
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SETUP_DESKTOP` | `false` | Install Hyprland desktop environment with Waybar, SDDM, PipeWire |
| `SETUP_FISH` | `false` | Install Fish shell alongside zsh with Starship prompt |
| `SETUP_CHROMIUM` | `true` | Install Chromium browser in addition to Firefox |

## What Gets Installed

### Always Installed
- Core development tools (git, neovim, docker, etc.)
- AUR helper (yay)
- Shell utilities (fzf, eza, bat, ripgrep, etc.)
- Fonts and terminal setup
- Productivity applications (VS Code, Slack, Spotify, etc.)

### Desktop Environment (when `SETUP_DESKTOP=true`)
- **Hyprland**: Wayland compositor with animations
- **Waybar**: Customizable status bar
- **SDDM**: Display manager for login
- **PipeWire**: Modern audio stack
- **Mako**: Notification daemon
- **Rofi**: Application launcher
- **Thunar**: File manager
- **Screenshot tools**: grim, slurp, swappy

### Fish Shell (when `SETUP_FISH=true`)
- **Fish**: Modern shell with autosuggestions
- **Starship**: Custom prompt
- Shell aliases and integrations

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
Edit `scripts/linux/arch.sh` and `scripts/linux/hyprland.sh` to add/remove packages.

### Customize Desktop Environment
Configuration files are in:
- `config/linux/hypr/` - Hyprland settings
- `config/linux/waybar/` - Status bar configuration
- `config/linux/mako/` - Notification settings

### Add New Applications
1. Install package via pacman or yay
2. Add to appropriate package array in setup script
3. Create configuration if needed in `config/` directory