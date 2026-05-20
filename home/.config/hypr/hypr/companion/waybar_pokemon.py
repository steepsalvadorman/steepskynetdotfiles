#!/usr/bin/env python3
"""
Pokemon GIF rotator for Waybar
Muestra un GIF aleatorio de pokémon cada media hora
"""

import os
import sys
import json
import time
import random
import requests
from pathlib import Path

POKEMON_DIR = Path.home() / ".config/hypr/companion/pokemon_gifs"
STATE_FILE = "/tmp/pokemon_state"
POKEMON_DIR.mkdir(parents=True, exist_ok=True)

# Lista de pokémon gen 1 (1-151)
POKEMON_LIST = list(range(1, 152))

def download_pokemon_gif(pokemon_id):
    """Descarga el GIF de un pokémon específico desde PokéAPI"""
    gif_path = POKEMON_DIR / f"pokemon_{pokemon_id}.gif"
    
    # Si ya existe, devolverlo
    if gif_path.exists():
        return gif_path
    
    try:
        # Usar la API de pokéapi.co para obtener la URL del GIF
        url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_id}"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            # Intentar obtener el GIF del sprite animado
            gif_url = data.get('sprites', {}).get('versions', {}).get('generation-v', {}).get('black-white', {}).get('animated', {}).get('front_default')
            
            if not gif_url:
                # Fallback a otros sprites animados
                gif_url = data.get('sprites', {}).get('front_default')
            
            if gif_url:
                # Descargar el GIF
                gif_response = requests.get(gif_url, timeout=5)
                if gif_response.status_code == 200:
                    with open(gif_path, 'wb') as f:
                        f.write(gif_response.content)
                    return gif_path
    except Exception as e:
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
    
    # Si han pasado menos de 30 minutos (1800 segundos), usar el mismo pokémon
    if last_pokemon_id and (current_time - last_time) < 1800:
        return last_pokemon_id
    
    # Seleccionar un pokémon aleatorio
    pokemon_id = random.choice(POKEMON_LIST)
    
    # Guardar el estado
    with open(STATE_FILE, 'w') as f:
        json.dump({
            'pokemon_id': pokemon_id,
            'timestamp': current_time
        }, f)
    
    return pokemon_id

def main():
    try:
        pokemon_id = get_current_pokemon()
        
        # Intentar descargar el GIF
        gif_path = download_pokemon_gif(pokemon_id)
        
        if gif_path and gif_path.exists():
            print(str(gif_path))
        else:
            # Si falla, mostrar una imagen PNG por defecto
            png_path = POKEMON_DIR / f"pokemon_{pokemon_id}.png"
            if not png_path.exists():
                try:
                    # Descargar PNG oficial
                    url = f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{pokemon_id}.png"
                    response = requests.get(url, timeout=5)
                    if response.status_code == 200:
                        with open(png_path, 'wb') as f:
                            f.write(response.content)
                except:
                    pass
            
            if png_path.exists():
                print(str(png_path))
            else:
                print("")  # Fallback vacío
    except Exception as e:
        print("")  # Fallback en caso de error

if __name__ == "__main__":
    main()
