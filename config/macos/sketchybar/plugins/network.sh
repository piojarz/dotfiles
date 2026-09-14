#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"

# Route-based rather than hardcoded to en0, so this keeps working whether
# the active connection is Wi-Fi, Ethernet, or a USB-C dock uplink.
IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"

if [ -z "$IFACE" ]; then
  sketchybar --set "$NAME" icon="$WIFI_DISCONNECTED" icon.color="$RED" label="Offline"
  exit 0
fi

# Requires Location Services permission for the calling process to resolve;
# falls back to the interface name (e.g. "en0") when it can't.
SSID="$(networksetup -getairportnetwork "$IFACE" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')"
LABEL="${SSID:-$IFACE}"

sketchybar --set "$NAME" icon="$WIFI_CONNECTED" icon.color="$ICON_COLOR" label="$LABEL"
