#!/usr/bin/env bash

set -euo pipefail

options="󰍃  Cerrar sesión
󰜉  Reiniciar
⏻  Apagar
󰤄  Suspender
󰌾  Bloquear"

choice=$(printf '%s\n' "$options" | wofi --dmenu \
    --prompt "Sesión" \
    --width 360 \
    --height 340 \
    --cache-file /dev/null)

[ -z "${choice:-}" ] && exit 0

confirm() {
    local action="$1"
    local answer

    answer=$(printf 'No, cancelar\nSí, continuar\n' | wofi --dmenu \
        --prompt "$action?" \
        --width 420 \
        --height 220 \
        --cache-file /dev/null)

    [ "$answer" = "Sí, continuar" ]
}

case "$choice" in
    *"Cerrar sesión"*)
        confirm "Cerrar sesión" && hyprctl dispatch exit
        ;;
    *"Reiniciar"*)
        confirm "Reiniciar" && systemctl reboot
        ;;
    *"Apagar"*)
        confirm "Apagar" && systemctl poweroff
        ;;
    *"Suspender"*)
        systemctl suspend
        ;;
    *"Bloquear"*)
        if command -v hyprlock >/dev/null 2>&1; then
            hyprlock
        elif command -v swaylock >/dev/null 2>&1; then
            swaylock
        else
            loginctl lock-session
        fi
        ;;
esac
