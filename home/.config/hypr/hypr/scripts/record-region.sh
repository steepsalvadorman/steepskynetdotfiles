#!/bin/bash

LOG="/tmp/record-region.log"
exec > "$LOG" 2>&1
echo "=== $(date) ==="
echo "USER=$USER HOME=$HOME"
echo "LANG=$LANG LC_CTYPE=$LC_CTYPE"

VIDEOS="$HOME/Vídeos"
echo "VIDEOS=$VIDEOS"
mkdir -p "$VIDEOS"
echo "mkdir: $?"

# Limpiar temps huérfanos de grabaciones anteriores fallidas
rm -f "$VIDEOS"/.tmp_*.mp4

if pgrep -f gpu-screen-recorder > /dev/null; then
    notify-send -u normal -t 3000 "Grabacion" "Ya hay una grabacion en curso"
    exit 1
fi

REGION=$(slurp -f "%wx%h+%x+%y") || exit 1
echo "REGION=$REGION"
AUDIO=$(pactl get-default-sink).monitor
echo "AUDIO=$AUDIO"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
TEMP="$VIDEOS/.tmp_$TIMESTAMP.mp4"
OUTPUT="$VIDEOS/captura_$TIMESTAMP.mp4"
echo "TEMP=$TEMP"
echo "OUTPUT=$OUTPUT"

notify-send -u low -t 3000 "Grabando region" "Super+Esc para detener"

gpu-screen-recorder \
    -w "$REGION" \
    -f 60 \
    -q high \
    -k h264 \
    -bm vbr \
    -fm vfr \
    -low-power yes \
    -a "$AUDIO" \
    -o "$TEMP"

echo "gsr exit: $?"
echo "TEMP exists: $([ -f "$TEMP" ] && echo SI || echo NO)"

if [ ! -f "$TEMP" ]; then
    notify-send -u critical -t 5000 "Grabacion fallida" "No se pudo guardar el archivo"
    exit 1
fi

notify-send -u low -t 5000 "Procesando grabacion" "Escalando a 720p..."

ffmpeg -i "$TEMP" \
    -vf "scale=1280:720:force_original_aspect_ratio=decrease:flags=lanczos,pad=1280:720:(ow-iw)/2:(oh-ih)/2:color=black" \
    -c:v h264_nvenc -preset p2 -cq 20 \
    -c:a copy \
    -y "$OUTPUT"

echo "ffmpeg exit: $?"
echo "OUTPUT exists: $([ -f "$OUTPUT" ] && echo SI || echo NO)"

rm -f "$TEMP"

if [ -f "$OUTPUT" ]; then
    SIZE=$(du -h "$OUTPUT" | cut -f1)
    notify-send -u normal -t 6000 "Grabacion guardada" "$(basename "$OUTPUT") — $SIZE"
else
    notify-send -u critical -t 5000 "Grabacion fallida" "Error al procesar el video"
fi

echo "=== FIN ==="
