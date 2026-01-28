# Hybrid Setup Guide

This document explains the hybrid approach to maintaining dotfiles with both shell scripts and Nix Home Manager.

## Why Hybrid Approach?

The hybrid approach provides several advantages:

1. **Gradual Migration** - Move to Nix at your own pace
2. **Safety Net** - Shell scripts as fallback if Nix issues occur
3. **Flexibility** - Choose best tool for each situation
4. **Learning Path** - Learn Nix while maintaining productivity
5. **Platform Testing** - Compare both approaches directly

## Quick Reference

### Setup Commands

```bash
# Auto-detect and use best available method
./setup.sh

# Control desktop setup
./setup.sh --desktop         # Desktop environment (Default on Arch)
./setup.sh --no-desktop      # Skip desktop setup
```

### Management Tools

```bash
# Environment variable bridge
./scripts/nix/nix-env.sh generate    # Create env files
./scripts/nix/nix-env.sh validate     # Check consistency
./scripts/nix/nix-env.sh show         # Show current settings

# Package synchronization
./scripts/nix/sync-packages.sh sync      # Sync Arch -> Nix
./scripts/nix/sync-packages.sh compare   # Compare packages
./scripts/nix/sync-packages.sh extract   # Extract from Arch

# Validation and migration
./scripts/nix/validate.sh validate    # Full validation
./scripts/nix/validate.sh test        # Test Nix build
./scripts/nix/validate.sh backup      # Create backup
./scripts/nix/validate.sh rollback    # Rollback options
```

## Decision Matrix

| Situation | Recommended Approach | Command |
|-----------|---------------------|---------|
| New user, want Nix | Use setup script | `./setup.sh` |
| Server setup | CLI-only setup | `./setup.sh --no-desktop` |
| System update | Full update | `./setup.sh` |

## Environment Variables

Always available across both systems:

```bash
export SETUP_DESKTOP=true    # Hyprland desktop environment with Noctalia
```

**Apply methods:**
- Export in shell before running setup
- Use command-line flags with `setup.sh`
- Edit in `scripts/nix/nix-env.sh`

## Configuration File Management

### Edit Once, Use Everywhere
Files in `config/` are read by both systems:

```bash
# Edit this file:
nvim config/linux/hypr/hyprland.conf

# Shell scripts use directly
./install.sh

# Nix reads automatically
home-manager switch --flake .
```

### File Locations
```
config/common/alacritty/alacritty.toml  # Both systems
config/common/fish/config.fish              # Both systems
config/linux/hypr/hyprland.conf         # Both systems
modules/linux/home/desktop/noctalia.nix   # Nix only
```

## Migration Workflow

### Phase 1: Parallel Setup
```bash
# Install traditional setup (existing)
./install.sh

# Install Nix setup side-by-side
./setup.sh --nix

# Test both independently
```

### Phase 2: Configuration Sync
```bash
# Make sure both use same configs
./scripts/nix/validate.sh compare

# Sync packages between systems
./scripts/nix/sync-packages.sh sync
```

### Phase 3: Gradual Transition
```bash
# Ensure desktop environment is ready
./setup.sh --desktop
```

### Phase 4: Nix-Only
```bash
# Full Nix setup
./setup.sh
```

## Troubleshooting Hybrid Setup

### Common Scenarios

#### Nix Build Fails, Shell Scripts Work
```bash
# Rollback to shell scripts
# Try setup again
./setup.sh
```

#### Configuration Not Applied in Nix
```bash
# Check if files exist
ls config/linux/hypr/hyprland.conf

# Test file reading
./scripts/nix/validate.sh validate

# Check permissions
ls -la config/common/
```

#### Package Conflicts
```bash
# Compare packages
./scripts/nix/sync-packages.sh compare

# Remove conflicting packages manually
# Update package lists in appropriate files
```

#### Environment Variable Issues
```bash
# Check current environment
./scripts/nix/nix-env.sh show

# Regenerate environment files
./scripts/nix/nix-env.sh generate

# Reload environment
source scripts/nix/.env
```

## Best Practices

### Daily Workflow
1. **Use unified setup script** for all changes
2. **Validate before applying** new configurations
3. **Keep packages synchronized** between systems
4. **Test both systems** when possible
5. **Document customizations** for reference

### Safety Measures
1. **Always backup** before major changes
2. **Test with dry-run** when possible
3. **Keep rollback plan** ready
4. **Monitor disk space** (dual systems use more)
5. **Regular validation** catch issues early

### Gradual Migration Tips
1. **Start with desktop environment** in Nix (clear boundaries)
2. **Keep development tools** in shell scripts initially
3. **Migrate terminal** (Alacritty/Fish) next
4. **Move dev tools** to Nix modules last
5. **Archive shell scripts** only when fully comfortable

## Emergency Procedures

### System Won't Start
```bash
# Boot to shell (emergency shell)
# Use shell script setup to restore
./install.sh --shell

# Or use minimal Nix rollback
home-manager rollback
```

### Corrupted Configuration
```bash
# Restore from backup
ls backups/
./setup.sh --shell  # or --nix

# Or reset to git state
git clean -fd
git checkout HEAD
./setup.sh --shell
```

### Disk Space Issues
```bash
# Clean Nix generations
home-manager expire 7d  # Remove generations older than 7 days

# Clean shell script caches
sudo pacman -Scc  # Clear package cache

# Monitor usage
df -h
du -sh ~/.local/share/nix/profile
```

## Advanced Hybrid Features

### Conditional Loading
Some modules load based on environment:

```nix
# Only install desktop packages if requested
home.packages = lib.mkIf (config.SETUP_DESKTOP) [hyprland noctalia];
```

### Cross-System Aliases
Create aliases that work in both systems:

```bash
# In config/common/fish/config.fish (for Fish)
# In config/common/zsh/.zshrc.d/aliases.zsh (for Zsh)

alias dots="./setup.sh"  # Unified setup command
alias dots-desktop="./setup.sh --desktop"
alias dots-nodektop="./setup.sh --no-desktop"
```

### Validation Integration
Regular automated validation:

```bash
# Add to crontab for weekly checks
0 9 * * 1 /path/to/dotfiles/scripts/nix/validate.sh validate

# Or run before important operations
./scripts/nix/validate.sh validate && ./setup.sh --nix
```

This hybrid approach provides maximum flexibility while enabling smooth migration to Nix at your own pace.