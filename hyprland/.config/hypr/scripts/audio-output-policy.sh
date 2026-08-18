#!/usr/bin/env bash

# Prefer connected Bluetooth audio. Otherwise, use the physical HDMI connector
# only when PipeWire reports that its HDMI port is available.

set -u -o pipefail

readonly HDMI_STATUS=/sys/class/drm/card0-HDMI-A-1/status
readonly NVIDIA_AUDIO_BUS_PATH=pci-0000:01:00.1

command -v jq >/dev/null 2>&1 || exit 0
command -v pactl >/dev/null 2>&1 || exit 0

bluetooth_sink() {
    local default_sink=$1

    jq -r --arg default_sink "$default_sink" '
		[.[] | select(
			.properties["device.bus"] == "bluetooth" or
			(.name | startswith("bluez_output."))
		)] as $sinks |
		($sinks | map(select(.name == $default_sink))[0] // .[0] // empty) |
		if type == "object" then .name else empty end
	'
}

hdmi_sink() {
    jq -r --arg bus_path "$NVIDIA_AUDIO_BUS_PATH" '
		[.[] | select(
			(.properties["device.bus_path"] == $bus_path or
				(.name | startswith("alsa_output.pci-0000_01_00.1."))) and
			any(.ports[]?; .type == "HDMI" and .availability == "available")
		)] |
		sort_by(.properties["priority.session"] // 0) |
		reverse |
		.[0].name // empty
	'
}

apply_policy() {
    local sinks
    local default_sink
    local target_sink
    local sink_input

    sinks=$(pactl -f json list sinks 2>/dev/null) || return
    default_sink=$(pactl get-default-sink 2>/dev/null || true)
    target_sink=$(bluetooth_sink "$default_sink" <<<"$sinks")

    if [[ -z $target_sink && -r $HDMI_STATUS ]] &&
        [[ $(<"$HDMI_STATUS") == connected ]]; then
        target_sink=$(hdmi_sink <<<"$sinks")
    fi

    # No preferred device is available, so leave fallback selection to WirePlumber.
    [[ -n $target_sink && $target_sink != "$default_sink" ]] || return

    pactl set-default-sink "$target_sink" || return
    while read -r sink_input; do
        pactl move-sink-input "$sink_input" "$target_sink" || true
    done < <(pactl -f json list sink-inputs 2>/dev/null | jq -r '.[].index')
}

while true; do
    apply_policy
    pactl subscribe 2>/dev/null | while read -r _; do
        apply_policy
    done
    sleep 1
done
