#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"

if pgrep -x kanata > /dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on icon.color="$RED" label.color="$RED"
fi
