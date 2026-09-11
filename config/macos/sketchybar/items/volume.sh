#!/usr/bin/env sh

sketchybar --add item volume right \
           --set volume icon.font="Symbols Nerd Font:Regular:17.0" \
                        script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change
