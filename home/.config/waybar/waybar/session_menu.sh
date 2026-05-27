#!/usr/bin/env bash

STYLE="$HOME/.config/wofi/power-menu.css"

run_menu() {
    wofi --show dmenu \
        --prompt "$1" \
        --style "$STYLE" \
        --width 300 \
        --cache-file /dev/null \
        --no-actions \
        --insensitive
}

OPTIONS="󰍃  Cerrar sesión
󰜉  Reiniciar
⏻  Apagar
󰤄  Suspender
󰌾  Bloquear"

choice=$(printf '%s\n' "$OPTIONS" | run_menu "󰐥  Power Menu" || true)

[ -z "$choice" ] && exit 0

confirm() {
    local answer
    answer=$(printf '  Cancelar\n  Confirmar\n' | run_menu "$1" || true)
    [ "$answer" = "  Confirmar" ]
}

case "$choice" in
    *"Cerrar sesión"*)
        confirm "󰍃  ¿Cerrar sesión?" && hyprctl dispatch exit
        ;;
    *"Reiniciar"*)
        confirm "󰜉  ¿Reiniciar?" && systemctl reboot
        ;;
    *"Apagar"*)
        confirm "⏻  ¿Apagar?" && systemctl poweroff
        ;;
    *"Suspender"*)
        systemctl suspend
        ;;
    *"Bloquear"*)
        loginctl lock-session
        ;;
esac
