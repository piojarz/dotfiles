#!/usr/bin/env sh

sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_window_change

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item "space.$sid" left \
        --subscribe "space.$sid" aerospace_workspace_change aerospace_window_change \
        --set "space.$sid" \
                              icon="$sid"                                    \
                              icon.padding_left=7                            \
                              icon.padding_right=7                           \
                              icon.highlight_color=$RED                      \
                              background.color=0x40ffffff                   \
                              background.corner_radius=5                    \
                              background.height=25                          \
                              background.drawing=off                        \
                              label.drawing=on                              \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.padding_left=6                          \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/space_windows.sh $sid"
done

sketchybar   --add item       separator left                          \
             --set separator  icon=                                  \
                              icon.font="Symbols Nerd Font:Regular:16.0" \
                              background.padding_left=15              \
                              background.padding_right=15             \
                              label.drawing=off                       \
                              icon.color=$WHITE
