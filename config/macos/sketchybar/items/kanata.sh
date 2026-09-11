#!/usr/bin/env sh

# Hidden while kanata is running; shows a red warning the moment it isn't, so
# a crashed/never-started remapper doesn't go unnoticed.
sketchybar --add item kanata right \
           --set kanata update_freq=30 \
                        icon="$KEYBOARD" \
                        icon.font="Symbols Nerd Font:Regular:17.0" \
                        label="kanata down" \
                        drawing=off \
                        script="$PLUGIN_DIR/kanata.sh"
