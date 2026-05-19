#!/usr/bin/env bash
set -u

OPCIONES="[run] Super + Q              : Abrir terminal (kitty)
[dir] Super + E              : Abrir archivos (thunar)
[app] Super + Space / R      : Abrir menu de aplicaciones (wofi)
[win] Super + C              : Cerrar ventana enfocada
[win] Super + V              : Alternar ventana flotante
[win] Super + F              : Pantalla completa
[win] Super + J              : Alternar split del layout
[nav] Super + Flechas        : Mover foco entre ventanas
[wks] Super + 1-5            : Cambiar workspace
[mov] Super + Shift + 1-5    : Mover ventana a workspace
[wks] Super + S              : Mostrar workspace especial
[mov] Super + Shift + S      : Mover ventana al workspace especial
[wks] Super + Rueda mouse    : Cambiar workspace anterior/siguiente
[ms]  Super + Click izq      : Mover ventana con mouse
[ms]  Super + Click der      : Redimensionar ventana con mouse
[scr] Print                  : Captura seleccionada, guardar y copiar
[sys] Super + W              : Cambiar wallpaper (Wallhaven)
[sys] Super + D              : Abrir dashboard multimedia
[bar] Super + B              : Ocultar / mostrar Waybar
[bri] Super + F1/F2/F3       : Brillo 40% / 70% / 100%
[bri] Tecla brillo arriba    : Quitar shader de pantalla
[vol] Teclas multimedia      : Subir, bajar o mutear volumen
[sys] Super + M              : Salir de Hyprland"

ELECCION=$(printf "%s\n" "$OPCIONES" | wofi --dmenu --prompt "Atajos Hyprland" --width 760 --height 560 --cache-file /dev/null)

if [ -z "$ELECCION" ]; then
    exit 0
fi

TITULO=$(printf "%s" "$ELECCION" | cut -d: -f1 | xargs)
DETALLE=$(printf "%s" "$ELECCION" | cut -d: -f2- | xargs)
notify-send -u low "$TITULO" "$DETALLE"
