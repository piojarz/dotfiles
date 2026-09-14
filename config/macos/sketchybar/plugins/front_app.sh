#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

ICON_MAP="$(dirname "$0")/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  APP="$INFO"
else
  # Forced initial run (sketchybar --update) has no $SENDER, so query the
  # current frontmost app directly instead of sitting blank until the next
  # app switch.
  APP="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
fi

[ -z "$APP" ] && exit 0

sketchybar --set "$NAME" label="$APP" icon="$("$ICON_MAP" "$APP")"
