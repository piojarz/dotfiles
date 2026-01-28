# Nix Integration Documentation

## Overview

This dotfiles repository now supports **dual management approaches**:
- **Traditional Shell Scripts** (existing functionality)
- **Nix Home Manager** (new declarative approach)

Both systems can be used simultaneously or independently, providing maximum flexibility during migration.

## Quick Start

### Install Home Manager (if not already installed)
```bash
# On NixOS or with flakes enabled
curl -L https://nixos.org/nix/install | sh

# On other distributions
nix --experimental-features "nix-command flakes" profile install nixpkgs#home-manager
```

### Unified Setup Script
The new `setup.sh` script automatically detects and chooses appropriate method:

```bash
# Auto-detect and use available method
./setup.sh

# Control desktop setup
./setup.sh --desktop      # Force desktop setup
./setup.sh --no-desktop   # Explicitly skip desktop setup

# With environment variables
SETUP_DESKTOP=true ./setup.sh             # Force desktop setup
```

### Direct Nix Usage
```bash
# Build and switch Nix configuration
home-manager switch --flake .

# Test without applying
home-manager build --flake . --dry-run

# List generations
home-manager generations

# Rollback to previous
home-manager rollback
```

## Configuration Structure

### Nix Files
```
flake.nix                    # Main flake definition
home.nix                     # Primary Home Manager configuration
nix/modules/                  # Modular Nix configurations
├── desktop.nix           # Hyprland, Waybar, Mako, Rofi
├── terminal.nix          # Alacritty, Fish shell
├── development.nix        # Development tools
├── packages.nix          # Additional packages
└── themes.nix             # GTK/cursor themes, fonts
```

### Traditional Files (unchanged)
```
scripts/linux/              # Arch Linux setup scripts
config/common/              # Cross-platform configs
config/linux/              # Linux-specific configs
```

## Environment Variables

Control behavior across both systems:

```bash
# Desktop environment (Hyprland + ecosystem)
export SETUP_DESKTOP=true
```

**Apply with:**
```bash
# For shell scripts
./scripts/nix/nix-env.sh generate

# For Nix
SETUP_DESKTOP=true ./setup.sh
```

## Package Management

### Nix Packages
All packages are managed declaratively in `nix/modules/`:

- **desktop.nix**: Hyprland, Waybar, Mako, Rofi, desktop utilities
- **terminal.nix**: Alacritty, Fish, shell tools
- **development.nix**: Git, Neovim, Docker, languages
- **packages.nix**: General utilities and applications
- **themes.nix**: Fonts, GTK themes, cursors

### Shell Script Packages
Maintained in `scripts/linux/arch.sh` with the same organization:

- Core packages (pacman)
- AUR packages (yay)
- Desktop-specific packages

### Package Synchronization
Keep both systems synchronized:

```bash
# Sync packages from Arch to Nix
./scripts/nix/sync-packages.sh sync

# Compare package lists
./scripts/nix/sync-packages.sh compare

# Extract packages from scripts
./scripts/nix/sync-packages.sh extract
```

## Configuration Files

### Reading Existing Configs
Nix modules read from existing configuration files:

```nix
# Example from nix/modules/desktop.nix
hyprlandConf = builtins.readFile ../../config/linux/hypr/hyprland.conf;
waybarConfig = builtins.fromJSON (builtins.readFile ../../config/linux/waybar/config);
```

### Configuration Management
- **Edit files** in `config/` directories (same as before)
- **Nix reads** from these files automatically
- **Shell scripts** use files directly
- **Single source of truth** maintained

## Validation Tools

Comprehensive validation and migration support:

```bash
# Validate Nix configuration
./scripts/nix/validate.sh validate

# Test Nix build
./scripts/nix/validate.sh test

# Compare package lists
./scripts/nix/validate.sh compare

# Create backup
./scripts/nix/validate.sh backup

# Show rollback options
./scripts/nix/validate.sh rollback
```

## Workflow Examples

### Initial Setup
```bash
# 1. Setup environment (do once)
./scripts/nix/nix-env.sh generate

# 2. Validate configuration
./scripts/nix/validate.sh validate

# 3. Build and switch
./setup.sh
```

### Development Workflow
```bash
# 1. Edit configuration files
nvim config/linux/hypr/hyprland.conf

# 2. Test changes (Nix)
./scripts/nix/validate.sh test

# 3. Apply changes (Nix)
home-manager switch --flake .

# 4. Test changes (Shell scripts - if still using)
./install.sh

# 5. Sync packages if needed
./scripts/nix/sync-packages.sh sync
```

### Daily Use
```bash
# Nix workflow
home-manager switch --flake .    # Rebuild
home-manager generations          # List versions
home-manager rollback           # Rollback

# Shell script workflow
./install.sh                # Reinstall

# Home Manager workflow
home-manager switch --flake .
```

## Migration Path

### From Shell Scripts to Nix
1. **Keep using shell scripts** - no immediate changes required
2. **Enable Nix alongside** - use `./setup.sh --nix` for testing
3. **Gradual migration** - move components one at a time
4. **Full Nix** - eventually use only Nix

### Rollback Strategies
- **Shell script rollback**: Reinstall with `./install.sh`
- **Nix rollback**: `home-manager rollback`
- **Hybrid rollback**: Choose method per-session

### Safe Migration Practices
```bash
# Always backup before major changes
./scripts/nix/validate.sh backup

# Test before applying
./scripts/nix/validate.sh test

# Validate after changes
./scripts/nix/validate.sh validate
```

## Troubleshooting

### Common Issues

#### "flake.nix not found"
```bash
# Ensure you're in the dotfiles directory
ls flake.nix

# Check current directory
pwd
```

#### "Package not found in Nixpkgs"
```bash
# Check if package needs overlay or AUR equivalent
# Some packages may need custom flakes or overlays
```

#### "Home Manager build failed"
```bash
# Test with dry run first
./scripts/nix/validate.sh test

# Check syntax
home-manager build --flake . --dry-run 2>&1 | less
```

#### Configuration not applied
```bash
# Ensure config files exist
ls config/linux/hypr/

# Check file permissions
ls -la config/common/alacritty/alacritty.toml

# Validate Nix can read files
./scripts/nix/validate.sh validate
```

## Advanced Usage

### Custom Flakes
Add custom inputs to `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    # Add custom flakes
    my-custom-overlay.url = "github:user/repo";
    hyprland.url = "github:hyprwm/Hyprland";
  };
}
```

### Package Overrides
Customize package versions or apply patches:

```nix
# In nix/modules/terminal.nix
programs.alacritty = {
  enable = true;
  package = pkgs.alacritty.overrideAttrs (old: {
    patches = [ ./alacritty-custom.patch ];
  });
};
```

### Conditional Configuration
Use environment variables for flexible setups:

```nix
# In home.nix
home.packages = lib.mkIf (config.SETUP_DESKTOP or false) (with pkgs; [
  # Only install if desktop environment requested
]);
```

## Contributing

### Adding New Modules
1. Create file in `nix/modules/`
2. Import in `home.nix`
3. Add configuration logic
4. Update documentation

### Package Mapping
Update `scripts/nix/sync-packages.sh` mappings:

```bash
# Add to package_map in sync-packages.sh
["new-package"]="nix-equivalent"
```

## Best Practices

1. **Always backup** before major changes
2. **Test before applying** configuration
3. **Use version control** for all changes
4. **Document customizations** for future reference
5. **Keep systems synchronized** during migration
6. **Validate both systems** regularly

## Support

### Resources
- [NixOS Manual](https://nixos.org/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Reddit](https://reddit.com/r/NixOS/)
- [Home Manager GitHub](https://github.com/nix-community/home-manager)