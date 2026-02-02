# Dotfiles Keybindings

Quick reference for all keyboard shortcuts across applications.

## System (Kanata)

| Key | Action |
|-----|--------|
| `Caps` (tap) | Escape |
| `Caps` (hold) | Control |
| `Right Alt` | Hyper (⌘⌥⇧⌃) |

---

## Common (All Platforms)

### Neovim

**Leader:** `Space`

#### Navigation
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between windows |
| `\` | Toggle Neo-tree |
| `]c` / `[c` | Next/previous git change |

#### Search (fzf-lua)
| Key | Action |
|-----|--------|
| `<leader>sf` | Search files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Search word under cursor |
| `<leader>sb` | Search buffers |
| `<leader>sh` | Search help |
| `<leader>sd` | Search diagnostics |
| `<leader>s.` | Recent files |
| `<leader>/` | Search in buffer |
| `<leader><leader>` | Find buffers |

#### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>rn` | Rename |
| `<leader>ca` | Code action |
| `<leader>th` | Toggle inlay hints |

#### Git (gitsigns)
| Key | Action |
|-----|--------|
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hu` | Undo stage |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` | Diff against index |
| `<leader>hD` | Diff against last commit |
| `<leader>tb` | Toggle blame line |
| `<leader>tD` | Toggle deleted |

#### Debug (DAP)
| Key | Action |
|-----|--------|
| `F5` | Start/Continue |
| `F1` | Step into |
| `F2` | Step over |
| `F3` | Step out |
| `F7` | Toggle DAP UI |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Set conditional breakpoint |

### Tmux

**Prefix:** `Ctrl+a`

| Key | Action |
|-----|--------|
| `Ctrl+a c` | New window |
| `Ctrl+a ,` | Rename window |
| `Ctrl+a &` | Kill window |
| `Ctrl+a |` | Split vertical |
| `Ctrl+a -` | Split horizontal |
| `Ctrl+a h/j/k/l` | Navigate panes |
| `Ctrl+a H/J/K/L` | Resize panes |
| `Ctrl+a r` | Reload config |
| `Ctrl+a y` | Sync panes |
| `Ctrl+a g` | Lazygit popup |
| `Ctrl+a s` | Session switcher (sesh) |
| `Ctrl+a T` | Toggle status bar |
| `Ctrl+a [` | Enter copy mode |
| `Ctrl+a p` | Paste |

### Kitty

| Key | Action |
|-----|--------|
| `Cmd/Ctrl+Shift+t` | New tab |
| `Cmd/Ctrl+Shift+w` | Close tab |
| `Cmd/Ctrl+Shift+c` | Copy |
| `Cmd/Ctrl+Shift+v` | Paste |
| `Cmd+1-9` | Go to tab (macOS) |

### Yazi (File Manager)

**Vim-style navigation**

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate (up/down/enter/leave) |
| `gg` / `G` | Go to top/bottom |
| `Ctrl+d/u` | Scroll half page |
| `~` / `/` | Go to home/root |
| `Space` | Toggle selection |
| `v` / `V` | Visual mode |
| `y` / `x` / `p` | Yank/cut/paste |
| `d` / `D` | Delete/trash |
| `a` / `A` | Create file/directory |
| `r` | Rename |
| `s` / `S` | Search (rg/fzf) |
| `t` | New tab |
| `[]` | Prev/next tab |
| `1-9` | Go to tab |
| `m` / `'` | Bookmarks |
| `w` | Task manager |
| `T` | Toggle preview |
| `q` / `Ctrl+c` | Quit |

---

## macOS Only

### Aerospace (Window Manager)

| Key | Action |
|-----|--------|
| `Alt+Enter` | Open terminal |
| `Alt+b` | Open browser |
| `Alt+q` | Close window |
| `Alt+f` | Fullscreen |
| `Alt+h/j/k/l` | Focus window |
| `Alt+Shift+h/j/k/l` | Move window |
| `Alt+1-9/0` | Go to workspace |
| `Alt+Shift+1-9/0` | Move to workspace |
| `Alt+minus/equal` | Resize window |
| `Alt+slash` | Toggle layout (tiles) |
| `Alt+comma` | Toggle layout (accordion) |
| `Alt+m` | Toggle floating |
| `Alt+Shift+space` | Balance sizes |
| `Alt+Shift+;` | Service mode |

**Service Mode:**
| Key | Action |
|-----|--------|
| `Esc` | Reload config |
| `r` | Reset layout |
| `f` | Toggle floating |
| `Backspace` | Close all but current |

---

## Linux Only

### Hyprland

**Modifier:** `Super` (Windows key)

| Key | Action |
|-----|--------|
| `Super+Return` | Open terminal |
| `Super+Space` | App launcher (rofi) |
| `Super+Tab` | Window switcher |
| `Super+q` | Close window |
| `Super+f` | Fullscreen |
| `Super+t` | Toggle floating |
| `Super+h/j/k/l` | Focus window |
| `Super+Shift+h/j/k/l` | Move window |
| `Super+r` | Resize mode |
| `Super+1-9/0` | Go to workspace |
| `Super+Shift+1-9/0` | Move to workspace |
| `Super+minus` | Toggle scratchpad |
| `Super+Escape` | Lock screen |
| `Super+Shift+e` | Logout menu |
| `Super+Shift+s` | Screenshot (area) |
| `Super+Print` | Screenshot (full) |
| `XF86AudioUp/Down` | Volume |
| `XF86BrightnessUp/Down` | Brightness |

**Resize Mode:**
| Key | Action |
|-----|--------|
| `h/j/k/l` | Resize direction |
| `Esc` | Exit resize mode |

---

## Quick Start

```bash
# Install everything
./install.sh

# Update
./update.sh
```
