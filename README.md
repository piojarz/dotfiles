# dotfiles

Personal dotfiles organized in the style of [nexxeln/dots](https://github.com/nexxeln/dots) with platform separation support for Linux, macOS, and common configurations.

## Structure

```
hosts/                    # Machine-specific configurations
├── linux-desktop/       # Example Linux desktop config
├── macos-laptop/        # Example macOS laptop config  
└── common-workstation/  # Shared workstation config

modules/                  # Reusable configuration modules
├── common/              # Cross-platform modules
│   └── home/
│       ├── shell/      # Fish, Zsh, Starship
│       ├── editors/    # Neovim
│       ├── tools/      # Git, ripgrep, fzf, bat, eza, lazygit
│       └── terminal/   # Tmux, Alacritty
├── linux/              # Linux-specific modules
│   └── home/
│       ├── desktop/    # Hyprland, Waybar, Rofi, Mako, Swaylock
│       └── terminal/   # Kitty
└── macos/              # macOS-specific modules
    └── home/
        ├── system/     # System Defaults
        └── terminal/   # Ghostty

config/                  # Preserved complex native configurations
├── common/              # Shared configs (kanata, nvim, git, tmux, etc.)
├── linux/              # Linux-specific configs (hypr, waybar, rofi, etc.)
└── macos/              # macOS-specific configs
```

## Usage

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the unified setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh [OPTIONS]
   ```

**What this script handles:**
- **Git Identity**: Prompts for your name/email on first setup.
- **User Detection**: Automatically detects your username and configures system paths.
- **Nix Modules**: Installs and configures all CLI tools and shells via Home Manager.
- **macOS integration**: Installs Homebrew, Casks (GUI apps), and system preferences.
- **Linux integration**: Sets up AUR helpers (yay) and enables systemd services.

### Options
- `--desktop`    : Enable desktop environment setup (Linux only, default: true on Arch)
- `--no-desktop` : Disable desktop environment setup
- `--help`       : Show all options

### Creating New Hosts

1. Create a new directory under `hosts/`:
   ```bash
   mkdir hosts/my-machine
   ```

2. Create a `default.nix` file importing desired modules:
   ```nix
   { config, lib, pkgs, ... }: {
     imports = [
       ../../modules/common/home/shell
       ../../modules/common/home/editors
       # Add other modules as needed
     ];

     home.username = "your-username";
     home.homeDirectory = "/home/your-username";
     home.stateVersion = "24.05";
     
     programs.home-manager.enable = true;
   }
   ```

3. Add the host to `flake.nix`:
   ```nix
   homeConfigurations."my-machine" = home-manager.lib.homeManagerConfiguration {
     inherit pkgs;
     modules = [ ./hosts/my-machine ];
   };
   ```

## Key Features & Architecture

### ✅ Zero Redundancy
- **Single Responsibility Modules**: Each module handles exactly one tool or function (e.g., `git.nix` only handles git).
- **No Package Duplication**: Packages are declared once in their specific module, not scattered across shells.

### 🛡️ Platform Separation with Fallbacks
- **Common modules**: Work seamlessly across all platforms.
- **Linux modules**: Exclusive to Linux (Desktop Environment, Wayland tools).
- **macOS modules**: Exclusive to macOS (System preferences, Karabiner).

### 🖥️ Native Configuration Support
- Complex configurations (like Neovim, Hyprland) are kept in `config/` in their native formats.
- Simple configurations are managed directly in Nix.
- This hybrid approach offers the best of both worlds: Nix reproducibility with native config flexibility.

## Available Configurations

### Terminal Integration Strategy
The setup uses a mutual exclusion strategy for terminals to ensure the best experience per platform:
- **Linux**: Defaults to **Kitty** (Native Wayland support).
- **macOS**: Defaults to **Ghostty** (Native macOS support).
- **Common**: **Alacritty** (Available as a reliable fallback).
- **Multiplexer**: **Tmux** configured with `sesh` for session management everywhere.

### Core Tools (Common)
- **Shell**: Fish and Zsh (interchangeable) with Starship prompt and Zoxide.
- **Editor**: Neovim with full Lua configuration (linked from `config/common/nvim`).
- **Utilities**: Git, ripgrep, fzf, bat, eza, lazygit.

### Linux Desktop (Hyprland)
- **Compositor**: Hyprland
- **Desktop Shell**: [Noctalia](https://noctalia.dev/) (Handles Bar, Notifications, Dashboard)
- **Launcher**: Rofi
- **Lock Screen**: Swaylock

### macOS System
- **Input**: Kanata for cross-platform keyboard customization.
- **System Settings**: Scripted defaults for cleaner UX.

## Contributing

Feel free to:
- Add new modules under appropriate platform directories (`modules/<platform>/home/`).
- Improve existing native configurations in `config/`.
- Share host configurations.

## License

Personal use. Feel free to adapt for your own needs.