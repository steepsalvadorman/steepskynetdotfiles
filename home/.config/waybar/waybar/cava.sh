#!/usr/bin/env python3
import subprocess
import sys

# Definimos el comando
cmd = ["cava", "-p", "/home/steepskynet/.config/cava/config"]

# Iniciamos el proceso
proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True,
    bufsize=1
)

# Estos caracteres son bloques que van subiendo de altura:
chars = [" ", " ", "▂", "▃", "▄", "▅", "▆", "█"]

# Colores arcoíris para el efecto
colors = ["#ff0000", "#ff7f00", "#ffff00", "#00ff00", "#0000ff", "#4b0082", "#9400d3"]

try:
    for line in proc.stdout:
        line = line.strip()
        if not line: continue

        values = line.split(";")
        output = ""
        
        for i, v in enumerate(values):
            if v.isdigit():
                val = int(v)
                # Normalizamos el valor al rango de nuestra lista de caracteres (0-7)
                index = max(0, min(val, 7))
                char = chars[index]
                
                # Asignamos color cíclico basado en la posición de la barra
                color = colors[i % len(colors)]
                
                # Aplicamos etiqueta Pango para el color
                output += f'<span color="{color}">{char}</span>'
        
        print(output, flush=True)
except KeyboardInterrupt:
    proc.kill()
