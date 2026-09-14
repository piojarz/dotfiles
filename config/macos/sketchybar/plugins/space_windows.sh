#!/bin/sh

SID="$1"
ICON_MAP="$(dirname "$0")/icon_map.sh"

# $FOCUSED_WORKSPACE only arrives via the aerospace_workspace_change event;
# on the forced initial run (sketchybar --update) it's unset, which used to
# leave every space unhighlighted until the first workspace switch. Fall back
# to querying aerospace directly so the active space is always correct.
FOCUSED="$FOCUSED_WORKSPACE"
[ -z "$FOCUSED" ] && FOCUSED="$(aerospace list-workspaces --focused)"

if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" background.drawing=on
else
    sketchybar --set "$NAME" background.drawing=off
fi

icons=""
while IFS= read -r app; do
    [ -z "$app" ] && continue
    icons="$icons$("$ICON_MAP" "$app")"
done <<EOF
$(aerospace list-windows --workspace "$SID" --format '%{app-name}' | awk '!seen[$0]++')
EOF

sketchybar --set "$NAME" label="$icons"
