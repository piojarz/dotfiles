{ config, pkgs, lib, ... }:

let
  # vesper colors
  colors = {
    bg = "#101010";
    bg_elevated = "#1A1A1A";
    bg_selected = "#232323";
    fg = "#FFFFFF";
    fg_muted = "#A0A0A0";
    fg_dim = "#5C5C5C";
    accent = "#FFC799";
    mint = "#99FFE4";
    border = "#282828";
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    keyMode = "vi";
    historyLimit = 50000;
    clock24 = true;
    sensibleOnTop = false;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # true color
      set -ag terminal-overrides ",*:RGB"

      # renumber windows
      set -g renumber-windows on

      # splits in cwd
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # new window in cwd
      unbind c
      bind c new-window -c "#{pane_current_path}"

      # pane nav without prefix
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # session switcher (sesh + gum)
      bind s display-popup -E -w 40% -h 40% "sesh connect $(sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder='Pick a sesh' --height=50 --prompt='⚡')"

      # open lazygit in a popup
      bind g display-popup -w "80%" -h "80%" -d "#{pane_current_path}" -E "lazygit"

      # reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

      # copy mode
      unbind [
      bind Escape copy-mode
      unbind p
      bind p paste-buffer
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # no bells
      set -g visual-activity off
      set -g visual-bell off
      setw -g monitor-activity off

      # status bar
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=${colors.bg} fg=${colors.fg_muted}"

      # left: session
      set -g status-left "#[fg=${colors.accent},bold] #S #[fg=${colors.fg_dim}]│ "

      # right: time only
      set -g status-right "#[fg=${colors.fg_muted}]%-I:%M %p "

      # window format
      setw -g window-status-format "#[fg=${colors.fg_dim}] #I #W "
      setw -g window-status-current-format "#[fg=${colors.fg},bold] #I #W "

      # pane borders
      set -g pane-border-style "fg=${colors.border}"
      set -g pane-active-border-style "fg=${colors.accent}"
    '';
  };

  # sessionizer script
  home.file.".config/tmux/scripts/sessionizer" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      SEARCH_DIRS=(~/code ~/projects ~/work ~/.config)
      selected=$(find $SEARCH_DIRS -maxdepth 2 -type d 2>/dev/null | fzf --prompt="Select directory: ")
      if [[ -n "$selected" ]]; then
          session_name=$(basename "$selected" | tr '.' '_')
          if tmux has-session -t="$session_name" 2>/dev/null; then
              tmux switch-client -t "$session_name"
          else
              tmux new-session -ds "$session_name" -c "$selected"
              tmux switch-client -t "$session_name"
          fi
      fi
    '';
  };

  home.packages = with pkgs; [
    tmux
    sesh
    gum
    # fzf is managed in its own module
  ];
}