#!/usr/bin/env sh

sketchybar --add item network right \
           --set network update_freq=10 \
                          icon.font="Symbols Nerd Font:Regular:16.0" \
                          click_script="open 'x-apple.systempreferences:com.apple.Network-Settings.extension'" \
                          script="$PLUGIN_DIR/network.sh" \
           --subscribe network system_woke
