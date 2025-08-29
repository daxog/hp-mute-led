#!/bin/bash
set -euo pipefail

previous_state=""

update_led_state() {
    local state="$1"
    local cmd="$([ "$state" = "ON" ] && echo "0x7778" || echo "0x7774")"
    sudo /usr/bin/hda-verb /dev/snd/hwC1D0 0x20 0x500 0x0B
    sudo /usr/bin/hda-verb /dev/snd/hwC1D0 0x20 0x400 "$cmd"
    previous_state="$state"
}

cleanup() {
    update_led_state "OFF"
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

while true; do
    sink=$(pactl info | awk '/Default Sink/ {print $3}')
    mute_status=$(pactl get-sink-mute "$sink" | awk '{print $2}')
    volume_level=$(pactl get-sink-volume "$sink" | awk '{print $5}' | tr -d '%')

    state=$([ "$mute_status" = "yes" ] || [ "$volume_level" -eq 0 ] && echo "ON" || echo "OFF")

    [[ "$state" != "$previous_state" ]] && update_led_state "$state"

    sleep 0.3
done
