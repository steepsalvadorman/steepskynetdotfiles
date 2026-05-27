#!/bin/bash
# OBS Recording/Stream Status Monitor

if ! command -v obs &> /dev/null; then
    echo "󰑊 OFF"
    exit 0
fi

# Verificar si OBS está corriendo
if pgrep -x "obs" > /dev/null; then
    # Intentar obtener estado via dbus/obs-websocket si existe
    # Fallback: mostrar que OBS está activo
    echo "󰑊 ON"
else
    echo "󰑊 OFF"
fi
