#!/bin/sh

source "$HOME/.config/sketchybar/icons.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

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
fi
