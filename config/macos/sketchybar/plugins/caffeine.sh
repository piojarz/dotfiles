#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Caffeine doesn't emit events sketchybar can subscribe to, and it can be
# toggled from its own menu bar icon just as easily as from here, so we poll
# its AppleScript-exposed `active` property instead of tracking state
# ourselves. `tell application "Caffeine"` launches the app if it isn't
# running, so guard on the process first rather than hiding the item that way.
if ! pgrep -qx Caffeine; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$1" = "--toggle" ]; then
  if [ "$(osascript -e 'tell application "Caffeine" to get active')" = "true" ]; then
    osascript -e 'tell application "Caffeine" to turn off' >/dev/null
  else
    osascript -e 'tell application "Caffeine" to turn on' >/dev/null
  fi
fi

ACTIVE="$(osascript -e 'tell application "Caffeine" to get active' 2>/dev/null)"

if [ "$ACTIVE" = "true" ]; then
  sketchybar --set "$NAME" drawing=on icon="$CAFFEINE" icon.color="$YELLOW"
else
  sketchybar --set "$NAME" drawing=on icon="$CAFFEINE" icon.color="$GREY"
fi
