# Yabai + SKHD Setup Instructions
# Replacing AeroSpace with Yabai for macOS window management

## Installation

### Quick Install (Recommended)
```bash
# Run the installation script
./install.sh
```

The script will:
1. Install yabai and skhd via Homebrew
2. Create the necessary symlinks to your dotfiles
3. Start the services automatically

### Manual Installation

#### 1. Install via Homebrew
```bash
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd
```

#### 2. Grant Permissions
After installation, you need to grant yabai and skhd the necessary permissions:

**Accessibility Permissions:**
1. Open System Settings → Privacy & Security
2. Select "Accessibility" from the sidebar
3. Add both `/usr/local/bin/yabai` and `/usr/local/bin/skhd`
4. Make sure both are checked/enabled

**Screen Recording Permissions** (required for newer macOS versions):
1. In the same Privacy settings, select "Screen Recording"
2. Add `/usr/local/bin/yabai`
3. Make sure it's checked/enabled

#### 3. Configure Setup Script
```bash
# Create symlinks to your dotfiles
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/yabairc ~/.yabairc
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/skhdrc ~/.skhdrc
chmod +x ~/.yabairc
chmod +x ~/.skhdrc
```

#### 4. Start Services
```bash
# Start services
brew services start yabai
brew services start skhd

# Or run them manually for testing
yabai --load-config
skhd --load-config
```

### 2. Grant Permissions
After installation, you need to grant yabai and skhd the necessary permissions:

#### Accessibility Permissions
1. Open System Preferences → Security & Privacy → Privacy
2. Click the lock icon and enter your password
3. Select "Accessibility" from the left sidebar
4. Add both `/usr/local/bin/yabai` and `/usr/local/bin/skhd`
5. Make sure both are checked/enabled

#### Screen Recording Permissions (required for newer macOS versions)
1. In the same Privacy settings, select "Screen Recording"
2. Add `/usr/local/bin/yabai`
3. Make sure it's checked/enabled

### 3. Configure Setup Script
```bash
# Create symlinks to your dotfiles
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/yabairc ~/.yabairc
ln -s /Users/pj/code/dotfiles_new/config/macos/yabai/skhdrc ~/.skhdrc
chmod +x ~/.yabairc
chmod +x ~/.skhdrc
```

### 4. Start Services
```bash
# Start the services
brew services start yabai
brew services start skhd

# Or run them manually for testing
yabai --load-config
skhd --load-config
```

## Key Bindings

The configuration matches Hyprland functionality:

| Function | Hyprland | Yabai/SKHD |
|----------|----------|------------|
| Terminal | `SUPER+Enter` | `alt+Enter` |
| Launcher | `SUPER+Space` | `alt+Space` |
| Close Window | `SUPER+Q` | `alt+Q` |
| Focus | `SUPER+H/J/K/L` | `alt+H/J/K/L` |
| Move Window | `SUPER+Shift+H/J/K/L` | `alt+Shift+H/J/K/L` |
| Workspaces | `SUPER+1-0` | `alt+1-0` |
| Move to Workspace | `SUPER+Shift+1-0` | `alt+Shift+1-0` |
| Screenshot | `SUPER+Shift+S` | `alt+Shift+S` |
| Lock Screen | `SUPER+Escape` | `alt+Escape` |

## Important Notes

1. **Alt vs Super**: Using `alt` instead of `SUPER` (cmd) to avoid conflicts with macOS system shortcuts
2. **SIP Requirements**: Some advanced yabai features may require disabling System Integrity Protection (SIP)
3. **Window Rules**: Apps like System Preferences, Activity Monitor, and 1Password are set to float by default
4. **Workspace Mapping**: Browser apps go to space 2, communication apps to space 3, mail to space 4, etc.

## Troubleshooting

### If yabai doesn't start:
- Check Accessibility permissions
- Make sure config files are executable: `chmod +x ~/.yabairc`
- Check logs: `brew services list`

### If skhd shortcuts don't work:
- Verify skhd is running: `brew services list`
- Check Accessibility permissions for skhd
- Reload config: `skhd --reload`

### For SIP-dependent features:
```bash
# Check SIP status
csrutil status

# Only disable if absolutely necessary and you know the risks
# Requires recovery mode boot
```

## Migration from AeroSpace

1. Stop AeroSpace: `pkill AeroSpace`
2. Remove AeroSpace from Login Items (System Preferences → Users & Groups → Login Items)
3. Follow the installation steps above
4. Reboot to ensure all permissions take effect