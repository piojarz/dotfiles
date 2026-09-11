#!/usr/bin/env sh

sketchybar --add item clock right \
           --set clock update_freq=10 \
                       icon= \
                       icon.font="Symbols Nerd Font:Regular:17.0" \
                       script="$PLUGIN_DIR/clock.sh"
