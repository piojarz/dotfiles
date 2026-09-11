#!/usr/bin/env sh

# Cross-session workmux agent status: hidden when no agents are waiting or
# working, otherwise a badge with a count. Polls `workmux status --all`
# rather than being event-driven, since workmux's hooks push status into
# tmux, not sketchybar.
sketchybar --add item workmux right \
           --set workmux update_freq=15 \
                         icon.font="Symbols Nerd Font:Regular:17.0" \
                         label.drawing=on \
                         drawing=off \
                         script="$PLUGIN_DIR/workmux.sh"
