#!/bin/bash
# Toggle Gaming Mode (estable)

MODE_FILE="/tmp/hyprland_gaming_mode"

eww_reset() {
  pkill eww 2>/dev/null
  eww kill 2>/dev/null
  sleep 0.5

  eww daemon

  until eww ping; do
    sleep 0.2
  done
}

if [ -f "$MODE_FILE" ]; then
    # =========================
    # SALIR DE GAMING MODE
    # =========================

    rm "$MODE_FILE"

    hyprctl reload

    # esperar estabilidad del compositor
    sleep 1.5

    # restaurar UI
    eww_reset
    eww open bar

    notify-send "Gaming Mode: OFF ✓"

else
    # =========================
    # ENTRAR A GAMING MODE
    # =========================

    touch "$MODE_FILE"

    # aplicar perfil gaming
    hyprctl load ~/.config/hypr/profiles/gaming.conf

    # matar UI para rendimiento
    pkill eww 2>/dev/null
    eww kill 2>/dev/null

    notify-send "Gaming Mode: ON 🎮"
fi
