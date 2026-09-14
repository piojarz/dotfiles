# Dotfiles Keybindings

Quick reference for all keyboard shortcuts across applications.

## System

Same mapping on both platforms, different tool per-OS: Karabiner-Elements complex modifications
on macOS, Kanata (`config/common/kanata/kanata.kbd`) on Linux.

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

Paired with [Sketchybar](#sketchybar-status-bar) — the bar's workspace indicators highlight the
focused workspace and show icons for whichever apps are open in it, driven by Aerospace's
`exec-on-workspace-change` and `on-window-detected` hooks.

| Key | Action |
|-----|--------|
| `Alt+H/J/K/L` | Focus window (left/down/up/right) |
| `Alt+Shift+H/J/K/L` | Move window |
| `Alt+Shift+H/J/K/L` (join) | Join with window in direction |
| `Alt+1-4` | Go to workspace |
| `Alt+Shift+1-4` | Move window to workspace (and follow) |
| `Alt+Tab` | Workspace back and forth |
| `Alt+Shift+Tab` | Move workspace to next monitor |
| `Alt+Slash` | Layout: tiles |
| `Alt+Comma` | Layout: accordion |
| `Alt+Ctrl+F` | Toggle floating/tiling |
| `Alt+Ctrl+Shift+F` | Fullscreen |
| `Alt+Shift+Minus/Equal` | Resize window |
| `Alt+Shift+;` | Service mode |
| `Alt+Shift+Enter` | Apps mode |

**Service Mode:**
| Key | Action |
|-----|--------|
| `Esc` | Reload config |
| `r` | Reset layout |
| `f` | Toggle floating |
| `Backspace` | Close all but current |

**Apps Mode:**
| Key | Action |
|-----|--------|
| `Alt+W` | Open WezTerm |

### Sketchybar (Status Bar)

Top bar showing: an  Apple menu (Preferences / Activity Monitor / Lock Screen), Aerospace
workspace indicators with per-app icons, the frontmost app name, clock, volume, network
(Wi-Fi/Ethernet status + SSID, click opens Network settings), battery, and Caffeine.app status
(click toggles it). `sketchybar-toggle` runs alongside it to auto-hide the bar near the screen
top so the native (auto-hidden) menu bar can show without overlapping.

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
