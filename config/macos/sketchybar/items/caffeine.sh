#!/usr/bin/env sh

# Caffeine.app status, mirrored here since it's easy to lose track of among
# native menu bar icons. Caffeine is AppleScript-scriptable (see
# Caffeine.sdef in the app bundle), so we poll its `active` property rather
# than tracking state ourselves, and toggle it the same way on click.
sketchybar --add item caffeine right \
           --set caffeine update_freq=5 \
                          icon.font="Symbols Nerd Font:Regular:17.0" \
                          label.drawing=off \
                          click_script="$PLUGIN_DIR/caffeine.sh --toggle" \
                          script="$PLUGIN_DIR/caffeine.sh"
