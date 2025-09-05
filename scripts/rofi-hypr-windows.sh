#!/usr/bin/env bash

# Get list of clients from hyprctl
windows=$(hyprctl clients -j | jq -r '.[] | "\(.workspace.name) | \(.class) - \(.title)"')

# Show with rofi
chosen=$(echo "$windows" | rofi -dmenu -i -p "Windows")

# Extract window address from selection
if [ -n "$chosen" ]; then
    # Get the class and title back to identify the window
    class=$(echo "$chosen" | awk -F'|' '{print $2}' | awk -F'-' '{print $1}' | xargs)
    title=$(echo "$chosen" | awk -F'-' '{print $2}' | xargs)

    # Find address by matching title
    addr=$(hyprctl clients -j | jq -r --arg title "$title" \
        '.[] | select(.title == $title) | .address')

    # Focus the window
    [ -n "$addr" ] && hyprctl dispatch focuswindow address:"$addr"
fi

