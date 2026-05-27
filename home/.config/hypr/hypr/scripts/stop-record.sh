#!/bin/bash

if pgrep -f gpu-screen-recorder > /dev/null; then
    notify-send -u low -t 2000 "Deteniendo grabacion" "Guardando archivo..."
    killall -SIGINT gpu-screen-recorder
else
    notify-send -u low -t 2000 "Grabacion" "No hay ninguna grabacion activa"
fi
