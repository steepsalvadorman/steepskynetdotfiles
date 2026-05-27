#!/bin/bash
set -u

LOCK_FILE="/tmp/wallpaper_change.lock"
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

WALL_DIR="$HOME/Imágenes/walls"
STATE_DIR="$HOME/.cache/wal"
STATE_FILE="$STATE_DIR/local-wallpaper-index"

mkdir -p "$STATE_DIR"

mapfile -d '' wallpapers < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \) \
        -print0 | sort -z
)

count="${#wallpapers[@]}"
[ "$count" -eq 0 ] && exit 1

index=0
[ -f "$STATE_FILE" ] && read -r index < "$STATE_FILE" || index=0
case "$index" in ''|*[!0-9]*) index=0 ;; esac
[ "$index" -ge "$count" ] && index=0

wallpaper="${wallpapers[$index]}"
next_index=$(( (index + 1) % count ))
printf '%s\n' "$next_index" > "$STATE_FILE"

# swww aplica el wallpaper sin bloquear
awww img "$wallpaper" \
    --transition-type random \
    --transition-fps 60 \
    --transition-duration 1

# dynamic_colors en proceso separado — no bloquea ni waybar ni el compositor
nohup "$HOME/.config/hypr/scripts/dynamic_colors.sh" "$wallpaper" \
    &>/tmp/dynamic_colors.log &
