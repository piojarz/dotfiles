#!/usr/bin/env sh

sketchybar --add item clock right \
           --set clock update_freq=10 \
                       icon="$CLOCK" \
                       icon.font="Symbols Nerd Font:Regular:17.0" \
                       click_script="open -a Calendar" \
                       script="$PLUGIN_DIR/clock.sh"
