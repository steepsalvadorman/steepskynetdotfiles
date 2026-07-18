#!/bin/bash
# Selector de historial de portapapeles (cliphist + wofi)
# Reemplaza el panel de portapapeles de Noctalia.

selected=$(cliphist list | wofi --dmenu --prompt "Portapapeles")
[ -n "$selected" ] || exit 0
echo "$selected" | cliphist decode | wl-copy
