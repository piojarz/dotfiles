#!/bin/sh

SID="$1"
ICON_MAP="$(dirname "$0")/icon_map.sh"

if [ "$SENDER" = "aerospace_workspace_change" ]; then
    if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
        sketchybar --set "$NAME" background.drawing=on
    else
        sketchybar --set "$NAME" background.drawing=off
    fi
fi

icons=""
while IFS= read -r app; do
    [ -z "$app" ] && continue
    icons="$icons$("$ICON_MAP" "$app")"
done <<EOF
$(aerospace list-windows --workspace "$SID" --format '%{app-name}' | awk '!seen[$0]++')
EOF

sketchybar --set "$NAME" label="$icons"
