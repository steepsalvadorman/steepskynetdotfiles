#!/bin/bash
# Wallpaper Daemon - Cambia de fondo de pantalla cada 30 minutos (1800 segundos)

# Esperar un poco al inicio de sesión para que el entorno cargue por completo
sleep 5

# Cargar el primer wallpaper inmediatamente
~/.config/hypr/scripts/wallhaven.sh

# Bucle infinito
while true; do
    sleep 1800
    ~/.config/hypr/scripts/wallhaven.sh
done
