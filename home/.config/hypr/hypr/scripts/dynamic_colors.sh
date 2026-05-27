#!/bin/bash
# ── Sincronizador de Colores Dinámicos para Hyprland y Waybar ──

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
    echo "Uso: $0 /ruta/al/wallpaper.jpg"
    exit 1
fi

# 1. Extraer colores con pywal
wal -i "$WALLPAPER" -n -q

[ ! -f "$HOME/.cache/wal/colors" ] && exit 1

# 2. Leer colores
mapfile -t colors < "$HOME/.cache/wal/colors"
c0="${colors[0]}" c1="${colors[1]}" c2="${colors[2]}"
c5="${colors[5]}" c6="${colors[6]}" c7="${colors[7]}"

# 3. Colores para Hyprland (borders)
cat > "$HOME/.cache/wal/colors-hyprland.conf" <<EOF
\$color_active1 = rgb(${c1//#/})
\$color_active2 = rgb(${c2//#/})
\$color_inactive = rgb(${c0//#/})
EOF

# 4. Colores para Waybar
cat > "$HOME/.cache/wal/waybar-colors.css" <<EOF
/* Generado por dynamic_colors.sh */
@define-color background ${c0};
@define-color foreground ${c7};
@define-color color0 ${c0}; @define-color color1 ${c1};
@define-color color2 ${c2}; @define-color color5 ${c5};
@define-color color6 ${c6}; @define-color color7 ${c7};
EOF

# 5. Actualizar borders de Hyprland sin reload completo
hyprctl keyword "general:col.active_border"   "rgb(${c1//#/}) rgb(${c2//#/}) 45deg"
hyprctl keyword "general:col.inactive_border" "rgb(${c0//#/})"

# 6. Waybar (si corre)
systemctl --user is-active --quiet waybar && systemctl --user reload waybar

# 7. Guardar acento para workspaces y próximo arranque de eww
echo -n "$c6" > "$HOME/.cache/wal/eww-accent.txt"
echo -n "$c5" > "$HOME/.cache/wal/eww-accent2.txt"

# 8. Actualizar defvars en eww EN VIVO — sin tocar disco, sin inotify, sin parpadeo
eww -c "$HOME/.config/eww" update wal_accent="$c6" wal_accent2="$c5"
