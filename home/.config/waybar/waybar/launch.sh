#!/usr/bin/env bash
set -u

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/waybar/waybar.log"

mkdir -p "$(dirname "$LOG")"

# 1. MATAR TODO AL INICIO: Nos aseguramos de limpiar CUALQUIER instancia previa de inmediato
pkill -9 -x waybar 2>/dev/null || true

# Esperar a que Wayland esté listo
for _ in {1..40}; do
    if [ -n "${WAYLAND_DISPLAY:-}" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/$WAYLAND_DISPLAY" ]; then
        break
    fi
    sleep 0.25
done

# 2. SEGUNDA LIMPIEZA POR SI ACASO: Evita que otra llamada simultánea cree una barra fantasma
pkill -9 -x waybar 2>/dev/null || true

# Lanzar Waybar limpiando el archivo de log anterior para que no crezca infinito
exec waybar -c "$CONFIG" -s "$STYLE" >"$LOG" 2>&1
