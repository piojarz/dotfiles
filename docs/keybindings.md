# Dotfiles Keybindings

Quick reference for all keyboard shortcuts across applications.

## System

Same mapping on both platforms, different tool per-OS: Karabiner-Elements complex modifications
on macOS, Kanata (`config/common/kanata/kanata.kbd`) on Linux.

| Key | Action |
|-----|--------|
| `Caps` (tap) | Escape |
| `Caps` (hold) | Control |
| `Left Alt`/`Left Option` | Hyper (⌘⌥⇧⌃) |

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
| `Ctrl+a s` | Workspace picker (sesh + fzf, `bin/sesh-pick`) |
| `Ctrl+a Tab` | Previous workspace (`sesh last`) |
| `Ctrl+a f` | Toggle this workspace's scratch terminal popup (`bin/tmux-scratch`) |
| `Ctrl+a P` | Review a GitHub PR in its own worktree session (`bin/pr-review`) |
| `Ctrl+a F` | tmux-fzf menu (windows, panes, sessions, processes, ...) |
| `Ctrl+a T` | Toggle status bar |
| `Ctrl+a Escape` | Enter copy mode |
| `Ctrl+a p` | Paste |

**Workspace picker (`Ctrl+a s`)** lists tmux sessions, the `[[session]]` entries in
`config/common/sesh/sesh.toml` and zoxide dirs. Picking one switches to its session, or creates
it in that directory.

| Key | Action |
|-----|--------|
| `Ctrl+a` / `Ctrl+t` / `Ctrl+g` / `Ctrl+x` | All / tmux sessions / config entries / zoxide |
| `Ctrl+f` | Git repos and worktrees under `~/code`, `~/Developer`, `~/work` |
| `Ctrl+d` | Kill the highlighted session |
| `Ctrl+p` | Review a GitHub PR instead (same as `Ctrl+a P`) |

PR review runs `workmux add --pr <N> --open-if-exists` from the repo's main worktree, so an
already-checked-out PR just reopens its session and a new one gets the project's workmux setup.

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

Used Ctrl+Alt (not plain Alt) throughout, since plain Alt+letter is used to type Polish
diacritics (e.g. Alt+L → Ł) on this layout. The plain ctrl-alt bindings (no Shift) below now
trigger off the Hyper key instead (Hyper's modifiers are Cmd+Ctrl+Alt+Shift); the Ctrl+Alt+Shift
bindings are unchanged and still need that physical 3-key chord — Hyper always carries Shift, so
there's no collision between the two tiers.

| Key | Action |
|-----|--------|
| `Hyper+H/J/K/L` | Focus window (left/down/up/right) |
| `Ctrl+Alt+Shift+H/J/K/L` | Move window |
| `Ctrl+Alt+Shift+H/J/K/L` (join) | Join with window in direction |
| `Hyper+1-9` | Go to workspace |
| `Ctrl+Alt+Shift+1-9` | Move window to workspace (and follow) |
| `Hyper+Tab` | Workspace back and forth |
| `Ctrl+Alt+Shift+Tab` | Move workspace to next monitor |
| `Hyper+Slash` | Layout: tiles |
| `Hyper+Comma` | Layout: accordion |
| `Hyper+F` | Toggle floating/tiling |
| `Ctrl+Alt+Shift+F` | Fullscreen |
| `Ctrl+Alt+Shift+Minus/Equal` | Resize window |
| `Ctrl+Alt+Shift+;` | Service mode |
| `Ctrl+Alt+Shift+Enter` | Apps mode |

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
| `Hyper+W` | Open Kitty |

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
