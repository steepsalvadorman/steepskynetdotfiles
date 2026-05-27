#!/bin/bash

LOG_FILE="/tmp/eww-startup.log"
{
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Iniciando eww bar ==="

    # 1. Matar instancias previas
    if pgrep -x "eww" > /dev/null 2>&1; then
        echo "Limpiando instancias previas..."
        pgrep -x "eww" | xargs -r kill -9 2>/dev/null
        sleep 0.5
    fi

    # 2. Sincronizar eww.css con colores wal actuales ANTES de iniciar
    #    (eww no está corriendo → sin inotify → sin auto-reload → sin parpadeo)
    if [ -f "$HOME/.cache/wal/eww-colors.css" ]; then
        python3 - <<'PYEOF'
import re, os
eww_css  = os.path.expanduser("~/.config/eww/eww.css")
wal_file = os.path.expanduser("~/.cache/wal/eww-colors.css")
with open(wal_file) as f:
    new_colors = "".join(l for l in f if l.startswith("@define-color")).rstrip()
with open(eww_css) as f:
    css = f.read()
css = re.sub(
    r"/\* WAL_COLORS_START \*/.*?/\* WAL_COLORS_END \*/",
    "/* WAL_COLORS_START */\n" + new_colors + "\n/* WAL_COLORS_END */",
    css, flags=re.DOTALL
)
with open(eww_css, "w") as f:
    f.write(css)
PYEOF
        echo "eww.css sincronizado con colores wal"
    fi

    # 3. Esperar a que el sistema esté listo
    sleep 1

    # 4. Iniciar daemon
    echo "Iniciando eww daemon..."
    if ! eww daemon 2>&1; then
        echo "ERROR: No se pudo iniciar eww daemon"
        exit 1
    fi

    sleep 1

    # 5. Abrir barra
    echo "Abriendo barra..."
    if eww open bar 2>&1; then
        echo "✓ ÉXITO: Barra abierta"

        # 6. Sincronizar defvars con colores actuales
        ACCENT=$(cat "$HOME/.cache/wal/eww-accent.txt"  2>/dev/null || echo "#B4D13A")
        ACCENT2=$(cat "$HOME/.cache/wal/eww-accent2.txt" 2>/dev/null || echo "#6A9633")
        eww update wal_accent="$ACCENT" wal_accent2="$ACCENT2"
        exit 0
    else
        echo "✗ FALLO"
        eww daemon --kill 2>/dev/null
        exit 1
    fi
} > "$LOG_FILE" 2>&1
