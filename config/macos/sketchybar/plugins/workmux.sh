#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# sketchybar isn't attached to a tmux/kitty session, so workmux can't
# auto-detect a backend from the environment — force it explicitly.
OUTPUT="$(WORKMUX_BACKEND=tmux workmux status --json --all 2>/dev/null)"

# Fail closed: a non-zero exit means the agents array can't be trusted (no
# tmux server running, no backend, a corrupt state file, ...), so hide the
# item rather than risk showing a false "all clear".
if [ $? -ne 0 ] || [ -z "$OUTPUT" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

WAITING="$(echo "$OUTPUT" | jq '[.agents[] | select(.status == "waiting")] | length')"
WORKING="$(echo "$OUTPUT" | jq '[.agents[] | select(.status == "working")] | length')"

if [ "$WAITING" -gt 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" drawing=on icon="$WORKMUX_WAITING" icon.color="$RED" label="$WAITING" label.color="$RED"
elif [ "$WORKING" -gt 0 ] 2>/dev/null; then
  sketchybar --set "$NAME" drawing=on icon="$WORKMUX_WORKING" icon.color="$ICON_COLOR" label="$WORKING" label.color="$LABEL_COLOR"
else
  sketchybar --set "$NAME" drawing=off
fi
