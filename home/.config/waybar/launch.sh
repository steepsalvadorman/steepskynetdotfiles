#!/usr/bin/env bash
set -u

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/waybar/waybar.log"

mkdir -p "$(dirname "$LOG")"

for _ in {1..40}; do
    if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/$WAYLAND_DISPLAY" ]; then
        break
    fi
    sleep 0.25
done

pkill -x waybar 2>/dev/null || true
exec waybar -c "$CONFIG" -s "$STYLE" >>"$LOG" 2>&1
