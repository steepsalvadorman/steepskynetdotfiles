#!/bin/bash
# Lanzador de Dashboard Multimedia de Anime y Lo-Fi

# 1. Asegurar que el servidor local de API en Python esté ejecutándose
if ! pgrep -f "server.py" > /dev/null; then
    python3 ~/.config/hypr/dashboard/server.py &
    sleep 0.2
fi

# 2. Lanzar Chromium en modo Aplicación Flotante
chromium --app="file:///home/steepskynet/.config/hypr/dashboard/index.html" \
         --class="dashboard-window" \
         --window-size=950,650 \
         --user-data-dir="/home/steepskynet/.config/hypr/dashboard/chrome-profile" &
