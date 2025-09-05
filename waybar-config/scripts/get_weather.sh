#!/usr/bin/env bash

# Default fallback location
DEFAULT_CITY="Dhaka"
DEFAULT_COUNTRY="Bangladesh"

# Function to get location from IP
get_location() {
    local city country
    city=$(curl -s -A "Mozilla/5.0" https://ipapi.co/city)
    country=$(curl -s -A "Mozilla/5.0" https://ipapi.co/country)

    if [[ -z "$city" || -z "$country" ]]; then
        city="$DEFAULT_CITY"
        country="$DEFAULT_COUNTRY"
    fi

    echo "${city}+${country}"
}

# Fetch weather with retries
fetch_weather() {
    local location="$1"
    local text tooltip
    local retries=5

    for ((i=1; i<=retries; i++)); do
        text=$(curl -s -A "Mozilla/5.0" "https://wttr.in/${location}?format=1")
        tooltip=$(curl -s -A "Mozilla/5.0" "https://wttr.in/${location}?format=4")

        if [[ -n "$text" && -n "$tooltip" ]]; then
            # Clean up multiple spaces
            text=$(echo "$text" | sed -E "s/\s+/ /g")
            tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
            echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
            return 0
        fi

        sleep 2
    done

    # Fallback if all retries fail
    echo "{\"text\":\"N/A\", \"tooltip\":\"Unable to fetch weather\"}"
    return 1
}

LOCATION=$(get_location)
fetch_weather "$LOCATION"


