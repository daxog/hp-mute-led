#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
bin_src="$script_dir/bin/hp-mute-led.sh"

service_src="$script_dir/systemd/hp-mute-led.service"
bin_destination="/usr/local/bin/hp-mute-led.sh"

user_service_destination="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/hp-mute-led.service"

sudoers_file="/etc/sudoers.d/hp-mute-led"

sudo curl -fsSL https://github.com/daxog/hp-mute-led/raw/main/bin/hp-mute-led.sh -o "$bin_destination"
sudo chmod +x "$bin_destination"

mkdir -p "$(dirname "$user_service_destination")"
curl -fsSL https://github.com/daxog/hp-mute-led/raw/main/systemd/hp-mute-led.service -o "$user_service_destination"

if [ ! -f "$sudoers_file" ]; then
    echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/hda-verb" | sudo tee "$sudoers_file" > /dev/null
    sudo chmod 440 "$sudoers_file"
fi

systemctl --user daemon-reload
systemctl --user enable --now "hp-mute-led.service"

echo "hp-mute-led installed"