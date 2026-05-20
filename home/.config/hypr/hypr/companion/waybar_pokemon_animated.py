#!/usr/bin/env python3
"""
Pokemon GIF animator for Waybar usando ImageMagick
Extrae frames del GIF y los alterna
"""

import os
import sys
import json
import time
import random
import subprocess
from pathlib import Path

POKEMON_DIR = Path.home() / ".config/hypr/companion/pokemon_gifs"
FRAMES_DIR = Path.home() / ".config/hypr/companion/pokemon_frames"
STATE_FILE = "/tmp/pokemon_state"
POKEMON_DIR.mkdir(parents=True, exist_ok=True)
FRAMES_DIR.mkdir(parents=True, exist_ok=True)

POKEMON_LIST = list(range(1, 152))

def download_pokemon_gif(pokemon_id):
    """Descarga el GIF de un pokémon específico desde PokéAPI"""
    gif_path = POKEMON_DIR / f"pokemon_{pokemon_id}.gif"
    
    if gif_path.exists():
        return gif_path
    
    try:
        import requests
        url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_id}"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            gif_url = data.get('sprites', {}).get('versions', {}).get('generation-v', {}).get('black-white', {}).get('animated', {}).get('front_default')
            
            if gif_url:
                gif_response = requests.get(gif_url, timeout=5)
                if gif_response.status_code == 200:
                    with open(gif_path, 'wb') as f:
                        f.write(gif_response.content)
                    return gif_path
    except:
        pass
    
    return None

def get_current_pokemon():
    """Obtiene el pokémon actual basado en la hora"""
    current_time = int(time.time())
    last_pokemon_id = None
    last_time = 0
    
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, 'r') as f:
                data = json.load(f)
                last_pokemon_id = data.get('pokemon_id')
                last_time = data.get('timestamp', 0)
        except:
            pass
    
    if last_pokemon_id and (current_time - last_time) < 1800:
        return last_pokemon_id
    
    pokemon_id = random.choice(POKEMON_LIST)
    
    with open(STATE_FILE, 'w') as f:
        json.dump({
            'pokemon_id': pokemon_id,
            'timestamp': current_time
        }, f)
    
    return pokemon_id

def extract_gif_frames(gif_path, pokemon_id):
    """Extrae frames del GIF usando ImageMagick"""
    frames_subdir = FRAMES_DIR / f"pokemon_{pokemon_id}"
    frames_subdir.mkdir(exist_ok=True)
    
    try:
        subprocess.run([
            'convert',
            '-coalesce',
            str(gif_path),
            str(frames_subdir / 'frame_%02d.png')
        ], capture_output=True, timeout=10, check=True)
        
        frames = sorted(list(frames_subdir.glob("frame_*.png")))
        return frames_subdir, len(frames)
    except Exception as e:
        return None, 0

def get_current_frame(pokemon_id):
    """Obtiene el frame actual del GIF basado en el tiempo"""
    frames_dir = FRAMES_DIR / f"pokemon_{pokemon_id}"
    
    if not frames_dir.exists():
        return None
    
    frames = sorted(list(frames_dir.glob("frame_*.png")))
    if not frames:
        return None
    
    # Cambiar frame cada 100ms
    frame_index = int((time.time() * 10) % len(frames))
    return frames[frame_index]

def main():
    try:
        pokemon_id = get_current_pokemon()
        
        # Descargar GIF si es necesario
        gif_path = download_pokemon_gif(pokemon_id)
        
        # Extraer frames si no existen
        frames_dir = FRAMES_DIR / f"pokemon_{pokemon_id}"
        if not frames_dir.exists() and gif_path:
            extract_gif_frames(gif_path, pokemon_id)
        
        # Obtener frame actual
        frame_path = get_current_frame(pokemon_id)
        
        if frame_path and frame_path.exists():
            print(str(frame_path))
        else:
            print("")
    except Exception as e:
        print("")

if __name__ == "__main__":
    main()
