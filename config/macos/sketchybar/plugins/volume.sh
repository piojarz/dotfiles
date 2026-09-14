#!/bin/sh

source "$HOME/.config/sketchybar/icons.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  # Forced initial run (sketchybar --update) has no $SENDER/$INFO, so read
  # the current volume directly instead of sitting blank until the next
  # volume change.
  SETTINGS="$(osascript -e 'get volume settings' 2>/dev/null)"
  case "$SETTINGS" in
    *"output muted:true"*) VOLUME=0 ;;
    *) VOLUME="$(echo "$SETTINGS" | sed -n 's/.*output volume:\([0-9]*\).*/\1/p')" ;;
  esac
fi

[ -z "$VOLUME" ] && exit 0

case "$VOLUME" in
  [6-9][0-9]|100) ICON="$VOLUME_HIGH"
  ;;
  [3-5][0-9]) ICON="$VOLUME_MED"
  ;;
  [1-9]|[1-2][0-9]) ICON="$VOLUME_LOW"
  ;;
  *) ICON="$VOLUME_MUTE"
esac

sketchybar --set "$NAME" icon="$ICON" label="$VOLUME%"
