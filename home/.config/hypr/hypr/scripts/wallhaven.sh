#!/bin/bash
set -u

WALL_DIR="$HOME/Imágenes/wallhaven"
STATE_DIR="$HOME/.cache/wal"
STATE_FILE="$STATE_DIR/local-wallpaper-index"

mkdir -p "$STATE_DIR"

mapfile -d '' wallpapers < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \) \
        -print0 | sort -z
)

count="${#wallpapers[@]}"
if [ "$count" -eq 0 ]; then
    echo "No hay wallpapers en $WALL_DIR"
    exit 1
fi

index=0
if [ -f "$STATE_FILE" ]; then
    read -r index < "$STATE_FILE" || index=0
fi

case "$index" in
    ''|*[!0-9]*) index=0 ;;
esac

if [ "$index" -ge "$count" ]; then
    index=0
fi

wallpaper="${wallpapers[$index]}"
next_index=$(( (index + 1) % count ))
printf '%s\n' "$next_index" > "$STATE_FILE"

awww img "$wallpaper" --transition-type random --transition-fps 60 --transition-duration 1
"$HOME/.config/hypr/scripts/dynamic_colors.sh" "$wallpaper"

echo "Wallpaper local aplicado: $wallpaper"
