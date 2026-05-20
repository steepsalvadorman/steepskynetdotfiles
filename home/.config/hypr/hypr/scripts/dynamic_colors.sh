#!/bin/bash
# ── Sincronizador de Colores Dinámicos para Hyprland, Waybar y Wofi ──

WALLPAPER="$1"
if [ -z "$WALLPAPER" ]; then
    echo "Uso: $0 /ruta/al/wallpaper.jpg"
    exit 1
fi

# 1. Ejecutar pywal
wal -i "$WALLPAPER" -n -q

if [ ! -f "$HOME/.cache/wal/colors" ]; then
    echo "Error: No se pudieron extraer los colores con pywal."
    exit 1
fi

# 2. Leer colores generados
mapfile -t colors < <(cat "$HOME/.cache/wal/colors")

c0=$(echo "${colors[0]}" | tr -d '#')
c1=$(echo "${colors[1]}" | tr -d '#')
c2=$(echo "${colors[2]}" | tr -d '#')
c3=$(echo "${colors[3]}" | tr -d '#')
c4=$(echo "${colors[4]}" | tr -d '#')
c5=$(echo "${colors[5]}" | tr -d '#')
c6=$(echo "${colors[6]}" | tr -d '#')
c7=$(echo "${colors[7]}" | tr -d '#')
c8=$(echo "${colors[8]}" | tr -d '#')

# 3. Convertir hex a RGB decimal ANTES del heredoc.
#    GTK usa CSS nivel 3: rgba(r, g, b, a) con comas — no el formato nivel 4.
r1=$((16#${c1:0:2})); g1=$((16#${c1:2:2})); b1=$((16#${c1:4:2}))
r2=$((16#${c2:0:2})); g2=$((16#${c2:2:2})); b2=$((16#${c2:4:2}))
r3=$((16#${c3:0:2})); g3=$((16#${c3:2:2})); b3=$((16#${c3:4:2}))
r4=$((16#${c4:0:2})); g4=$((16#${c4:2:2})); b4=$((16#${c4:4:2}))
r5=$((16#${c5:0:2})); g5=$((16#${c5:2:2})); b5=$((16#${c5:4:2}))
r6=$((16#${c6:0:2})); g6=$((16#${c6:2:2})); b6=$((16#${c6:4:2}))
r7=$((16#${c7:0:2})); g7=$((16#${c7:2:2})); b7=$((16#${c7:4:2}))
r8=$((16#${c8:0:2})); g8=$((16#${c8:2:2})); b8=$((16#${c8:4:2}))

# 4. Escribir colores para Hyprland
cat > "$HOME/.cache/wal/colors-hyprland.conf" <<EOF
\$color_active1 = rgb($c1)
\$color_active2 = rgb($c2)
\$color_inactive = rgb($c0)
EOF

# 5. Regenerar CSS dinámico de Waybar.
#    El style.css principal hace @import de este archivo.
#    SIGUSR2 recarga el CSS sin matar Waybar.
cat > "$HOME/.cache/wal/waybar-colors.css" <<EOF
/* Generado automáticamente por dynamic_colors.sh — no editar a mano */

window#waybar {
    color: #${c7};
}

window#waybar > box {
    background: rgba(10, 10, 14, 0.72);
    border: 1px solid #${c1};
    border-radius: 5px;
    box-shadow: 0 0 18px rgba(${r1}, ${g1}, ${b1}, 0.35);
}

window#waybar #workspaces,
window#waybar #clock,
window#waybar #pulseaudio,
window#waybar #network,
window#waybar #tray,
window#waybar #cpu,
window#waybar #memory,
window#waybar #temperature,
window#waybar #mpris,
window#waybar #cava,
window#waybar #custom-brightness,
window#waybar #custom-guias {
    color: rgba(${r7}, ${g7}, ${b7}, 0.45);
    border-bottom: 1px solid rgba(${r7}, ${g7}, ${b7}, 0.08);
}

window#waybar #workspaces button {
    color: rgba(${r7}, ${g7}, ${b7}, 0.35);
}

window#waybar #workspaces button.active {
    color: #${c7};
    border-bottom: 1px solid #${c1};
    text-shadow: 0 0 8px rgba(${r1}, ${g1}, ${b1}, 0.7);
}

window#waybar #workspaces button:hover,
window#waybar #workspaces button:active {
    color: #${c7};
    border-bottom: 1px solid #${c2};
    text-shadow: 0 0 8px rgba(${r2}, ${g2}, ${b2}, 0.6);
}

window#waybar #workspaces button.urgent,
window#waybar #temperature.critical,
window#waybar #network.disconnected {
    color: #${c4};
    border-bottom-color: #${c4};
    text-shadow: 0 0 8px rgba(${r4}, ${g4}, ${b4}, 0.75);
}

window#waybar #clock {
    color: #${c3};
    border-bottom: 1px solid rgba(${r3}, ${g3}, ${b3}, 0.5);
    text-shadow: 0 0 6px rgba(${r3}, ${g3}, ${b3}, 0.4);
}

window#waybar #clock:hover,
window#waybar #clock:active {
    border-bottom-color: #${c3};
    text-shadow: 0 0 10px rgba(${r3}, ${g3}, ${b3}, 0.8);
}

window#waybar #mpris,
window#waybar #temperature {
    color: #${c2};
    border-bottom: 1px solid rgba(${r2}, ${g2}, ${b2}, 0.2);
}

window#waybar #mpris:hover,
window#waybar #mpris:active,
window#waybar #temperature:hover,
window#waybar #temperature:active {
    border-bottom-color: #${c2};
    text-shadow: 0 0 8px rgba(${r2}, ${g2}, ${b2}, 0.7);
}

window#waybar #cava,
window#waybar #cpu {
    color: #${c1};
    border-bottom: 1px solid rgba(${r1}, ${g1}, ${b1}, 0.2);
}

window#waybar #cava:hover,
window#waybar #cava:active,
window#waybar #cpu:hover,
window#waybar #cpu:active {
    border-bottom-color: #${c1};
    text-shadow: 0 0 8px rgba(${r1}, ${g1}, ${b1}, 0.7);
}

window#waybar #custom-brightness,
window#waybar #memory {
    color: #${c6};
    border-bottom: 1px solid rgba(${r6}, ${g6}, ${b6}, 0.2);
}

window#waybar #custom-brightness:hover,
window#waybar #custom-brightness:active,
window#waybar #memory:hover,
window#waybar #memory:active {
    border-bottom-color: #${c6};
    text-shadow: 0 0 8px rgba(${r6}, ${g6}, ${b6}, 0.7);
}

window#waybar #pulseaudio,
window#waybar #network {
    color: #${c5};
    border-bottom: 1px solid rgba(${r5}, ${g5}, ${b5}, 0.2);
}

window#waybar #pulseaudio:hover,
window#waybar #pulseaudio:active,
window#waybar #network:hover,
window#waybar #network:active {
    border-bottom-color: #${c5};
    text-shadow: 0 0 8px rgba(${r5}, ${g5}, ${b5}, 0.7);
}

window#waybar #pulseaudio.muted {
    color: rgba(${r8}, ${g8}, ${b8}, 0.45);
    border-bottom-color: transparent;
}

window#waybar #custom-guias {
    color: #${c4};
    border-bottom: 1px solid rgba(${r4}, ${g4}, ${b4}, 0.2);
}

window#waybar #custom-guias:hover,
window#waybar #custom-guias:active {
    border-bottom-color: #${c4};
    text-shadow: 0 0 8px rgba(${r4}, ${g4}, ${b4}, 0.7);
}
EOF

# 6. Recargar Hyprland (colores de borde de ventanas)
hyprctl reload

# 7. Recargar Waybar en caliente — recarga CSS sin matar el proceso
pkill -SIGUSR2 waybar

echo "¡Colores sincronizados con éxito!"
