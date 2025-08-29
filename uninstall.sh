#!/bin/bash
set -euo pipefail

bin_destination="/usr/local/bin/hp-mute-led.sh"
user_service_destination="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/hp-mute-led.service"

sudoers_file="/etc/sudoers.d/hp-mute-led"

systemctl --user disable --now "hp-mute-led.service" || true

sudo rm -f "$bin_destination"
rm -f "$user_service_destination"

if [ -f "$sudoers_file" ]; then
    sudo rm -f "$sudoers_file"
fi

systemctl --user daemon-reload

echo "hp-mute-led uninstalled"
