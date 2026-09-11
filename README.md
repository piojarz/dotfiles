# Dotfiles

Personal dotfiles for macOS and Arch Linux, managed via symlinks into `$XDG_CONFIG_HOME`.

## Layout

- `config/common/` — shared config, symlinked on both platforms (zsh, tmux, git, nvim, kitty, lazygit, yazi, zellij, worktrunk, claude, ...)
- `config/macos/` — macOS-only config (aerospace, sketchybar)
- `config/linux/` — Linux-only config (hyprland, rofi, hyprpanel, uwsm)
- `scripts/` — install/update logic, split into `common/`, `macos/`, `linux/`
- `bin/` — scripts symlinked onto `$PATH` (e.g. `git-bare-clone`)
- `docs/` — reference docs, including the [keybindings cheat sheet](docs/keybindings.md)

## Quick Start

```bash
# Install everything
./install.sh

# Update
./update.sh
```

`install.sh` symlinks config into place, installs packages (Homebrew on macOS / pacman+yay on Arch), and sets up shell, git, and OS preferences. `update.sh` refreshes packages and plugins without re-running the full install.
