# Dotfiles

A comprehensive dotfiles repository for macOS and Arch Linux, featuring automated setup, keyboard remapping with Kanata, and modern CLI tools.

## Features

- **Cross-Platform**: Works on macOS and Arch Linux
- **Keyboard Remapping**: Kanata replaces Karabiner (caps→esc/ctrl, right alt→hyper)
- **Modern Shell**: Zsh with Oh-My-Posh, Antidote plugin manager
- **Development Tools**: Neovim, Tmux, FZF, Ripgrep, and more
- **Window Management**: Aerospace (macOS) / Hyprland (Arch Linux Wayland compositor)
- **Status Bar**: Hyprpanel with Tokyo Night theme
- **Application Launcher**: Rofi with Tokyo Night theme
- **Automated Setup**: One-command installation with backup support

## Prerequisites

### macOS
- macOS 11.0 (Big Sur) or later
- Homebrew will be installed automatically if not present

### Arch Linux
- Base Arch installation with `sudo` access
- `base-devel` package group

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Run the installer**:
   ```bash
   ./install.sh
   ```

   The installer will:
   - Backup existing configurations
   - Create symlinks for all configs
   - Install required packages
   - Set up Kanata keyboard remapping
   - Configure your shell

3. **Restart your terminal** to apply all changes.

## Post-Installation

### Kanata Keyboard Remapping (Required)

Kanata provides your custom keyboard mappings and requires manual setup:

#### macOS
1. Grant accessibility permissions:
   - System Preferences → Security & Privacy → Privacy → Accessibility
   - Click the lock and add `/opt/homebrew/bin/kanata` (Apple Silicon) or `/usr/local/bin/kanata` (Intel)

2. Start the service:
   ```bash
   launchctl load ~/Library/LaunchAgents/com.kanata.kanata.plist
   ```

3. Verify it's working:
   ```bash
   launchctl list | grep kanata
   ```

#### Arch Linux
1. Add your user to the `input` group (log out and back in after):
   ```bash
   sudo usermod -aG input $USER
   ```

2. Enable and start the service:
   ```bash
   systemctl --user enable kanata.service
   systemctl --user start kanata.service
   ```

3. Verify it's working:
   ```bash
   systemctl --user status kanata.service
   ```

### Aerospace (macOS Window Management)

Aerospace is installed but needs accessibility permissions:

1. System Preferences → Security & Privacy → Privacy → Accessibility
2. Add `/Applications/Aerospace.app`

Then start it:
```bash
open -a Aerospace
```

### Hyprland (Arch Linux Wayland Compositor)

Hyprland is configured with auto-start on TTY1 login.

#### First Time Setup

1. **Place a wallpaper** (required for hyprpaper and hyprlock):
   ```bash
   mkdir -p ~/wallpapers
   cp /path/to/your/wallpaper.jpg ~/wallpapers/default.jpg
   ```

2. **Login on TTY1** - Hyprland will auto-start automatically
   - If not on TTY1, switch with `Ctrl+Alt+F1`
   - Or manually start with: `Hyprland`

3. **Configure displays** (if needed):
   ```bash
   # List monitors
   hyprctl monitors
   
   # Add to ~/.config/hypr/hyprland.conf:
   # monitor=DP-1,1920x1080@144,0x0,1
   ```

#### Hyprland Key Bindings

| Shortcut | Action |
|----------|--------|
| `Super+Return` | Open terminal (kitty) |
| `Super+Space` | Application launcher (rofi) |
| `Super+Tab` | Window switcher (rofi) |
| `Super+Q` | Close window |
| `Super+F` | Toggle fullscreen |
| `Super+T` | Toggle floating |
| `Super+H/J/K/L` | Focus left/down/up/right |
| `Super+Shift+H/J/K/L` | Move window |
| `Super+R` | Resize mode |
| `Super+[0-9]` | Switch workspace |
| `Super+Shift+[0-9]` | Move window to workspace |
| `Super+Escape` | Lock screen (hyprlock) |
| `Super+Shift+E` | Logout menu (wlogout) |
| `Super+Shift+S` | Screenshot (selection) |
| `Super+Print` | Screenshot (full screen) |

#### Hyprpanel

Top status bar with:
- Workspaces
- Window title
- Media controls
- System tray
- Volume/Network/Bluetooth/Battery
- Clock

#### Troubleshooting Hyprland

**Black screen / no wallpaper:**
```bash
# Check if wallpaper exists
ls ~/wallpapers/default.jpg

# Restart hyprpaper
killall hyprpaper && hyprpaper
```

**Kanata not working:**
```bash
# Check kanata status
systemctl --user status kanata

# Restart kanata
systemctl --user restart kanata
```

**Hyprland won't auto-start:**
```bash
# Check .zprofile exists
cat ~/.zprofile

# Start manually
Hyprland
```

### TPM (Tmux Plugin Manager)

After first tmux launch, install plugins:
```bash
# Inside tmux
Ctrl-a + I (capital i)
```

## Keyboard Mappings

### Kanata Remappings

| Key | Action |
|-----|--------|
| `Caps Lock` (tap) | Escape |
| `Caps Lock` (hold) | Control |
| `Right Alt/Option` | Hyper (⌘⌥⇧⌃) |

### Tmux Prefix
`Ctrl-a` (changed from default Ctrl-b)

### Common Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl-a c` | New window |
| `Ctrl-a ,` | Rename window |
| `Ctrl-a &` | Kill window |
| `Ctrl-a %` | Split vertical |
| `Ctrl-a "` | Split horizontal |
| `Ctrl-a h/j/k/l` | Navigate panes |

## Directory Structure

```
.
├── bin/                    # Utility scripts
├── config/
│   ├── common/            # Shared configs (Linux & macOS)
│   │   ├── git/
│   │   ├── kanata/        # Keyboard remapping config
│   │   ├── kitty/         # Terminal emulator
│   │   ├── lazygit/
│   │   ├── nvim/          # Neovim config
│   │   ├── ripgrep/
│   │   ├── sesh/          # Tmux session manager
│   │   ├── tmux/
│   │   └── zsh/
│   ├── linux/             # Arch Linux-specific configs
│   │   ├── hypr/          # Hyprland compositor
│   │   ├── hyprpanel/     # Status bar
│   │   └── rofi/          # Application launcher
│   └── macos/             # macOS-specific configs
│       ├── aerospace/     # Window manager
│       └── hammerspoon/   # Automation
├── scripts/
│   ├── common/            # Shared installation scripts
│   ├── linux/             # Arch Linux setup
│   └── macos/             # macOS setup
├── Brewfile               # macOS packages
├── install.sh             # Main installer
├── update.sh              # Update dotfiles
└── README.md
```

## Managing Dotfiles

### Update Configurations

To update your dotfiles after making changes:

```bash
./update.sh
```

This will:
- Pull latest changes from git
- Update all git submodules and plugins
- Reload shell configurations
- Update zsh plugins via antidote

### Add New Configurations

Use the provided helper script:

```bash
./bin/dotfiles-add path/to/new/config
```

This will:
- Copy the config to the appropriate location
- Create the necessary symlink
- Stage it for commit

### Edit Configurations

Edit files directly in `~/dotfiles/` and changes are immediately reflected.

### Backup Location

All backed up configurations are stored in:
```
~/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)/
```

## Troubleshooting

### Kanata not working on macOS

1. Check accessibility permissions (most common issue)
2. Verify kanata is running: `ps aux | grep kanata`
3. Check logs: `cat /tmp/kanata.out` and `cat /tmp/kanata.err`
4. Test manually: `kanata --cfg ~/.config/kanata/kanata.kbd`

### Kanata not working on Linux

1. Verify uinput module: `lsmod | grep uinput`
2. Check user groups: `groups $USER` should include `input`
3. Test manually: `kanata --cfg ~/.config/kanata/kanata.kbd`
4. Check service logs: `journalctl --user -u kanata`

### Zsh plugins not loading

1. Ensure antidote is installed: `ls -la ~/.antidote`
2. Reload zsh: `source ~/.zshrc`
3. Update plugins: `antidote update`

### Permission denied errors

Make sure scripts are executable:
```bash
chmod +x install.sh update.sh
chmod +x bin/*
```

## Shellcheck Validation

All shell scripts are validated with Shellcheck in CI. To check locally:

```bash
# Install shellcheck
brew install shellcheck  # macOS
sudo pacman -S shellcheck  # Arch

# Run checks
shellcheck install.sh
shellcheck scripts/**/*.sh
```

## Customization

### Adding New Packages

- **macOS**: Edit `Brewfile` and run `brew bundle`
- **Arch**: Edit `scripts/linux/arch.sh` in the `core_packages` or `aur_packages` arrays

### Modifying Keyboard Mappings

Edit `config/common/kanata/kanata.kbd` and restart the kanata service.

### Zsh Configuration

- Aliases: `config/common/zsh/.zshrc.d/aliases.zsh`
- Functions: `config/common/zsh/.zfunctions/`
- Plugins: `config/common/zsh/.zsh_plugins.txt`

## Uninstallation

To remove dotfiles and restore backups:

```bash
# Remove symlinks
./scripts/common/symlinks.sh  # Note: needs modification for removal

# Restore from backup (if available)
cp -r ~/.dotfiles-backup/latest/* ~/

# Stop services
# macOS:
launchctl unload ~/Library/LaunchAgents/com.kanata.kanata.plist

# Arch:
systemctl --user stop kanata.service
systemctl --user disable kanata.service
```

## License

MIT License - Feel free to use and modify as needed.

## Acknowledgments

- [Kanata](https://github.com/jtroo/kanata) for keyboard remapping
- [Antidote](https://github.com/mattmc3/antidote) for zsh plugin management
- [Aerospace](https://github.com/nikitabobko/aerospace) for window management
- [Oh-My-Posh](https://ohmyposh.dev/) for the shell prompt
