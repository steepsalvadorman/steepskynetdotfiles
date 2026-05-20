# 🐱 PokéFetch - Fastfetch con Pokémon

Una versión personalizada de Fastfetch que muestra información del sistema con un Pokémon aleatorio que cambia cada 30 minutos. Inspirado en **Hyde Dotfiles**.

## 📋 Características

✅ **Pokémon Aleatorio** - Cambia cada 30 minutos automáticamente
✅ **Animación GIF** - Los pokemones se animan en waybar
✅ **Información del Sistema** - OS, Kernel, Uptime, RAM, GPU, Disk, etc.
✅ **Nerd Fonts** - Usa JetBrainsMono Nerd Font para emojis perfectos
✅ **Cache Local** - Descarga y cachea las imágenes localmente
✅ **Estilo Hyde** - Inspirado en los dotfiles de Hyde

## 🚀 Uso

### Comando Corto
```bash
pokefetch
# o
pf
```

### Ejecutar al Abrir Terminal
Descomenta la última línea en `~/.zshrc`:
```bash
# En ~/.zshrc
pokefetch
```

### Configuración
Edita `~/.config/pokefetch/config.json` para personalizar:
- Colores
- Información mostrada
- Intervalo de rotación
- Usar imágenes PNG o solo información

## 📁 Archivos Principales

```
~/.config/hypr/companion/
├── pokefetch.sh                 # Script principal
├── waybar_pokemon_animated.py   # Integración con waybar
├── pokemon_gifs/                # GIFs descargados
└── pokemon_frames/              # Frames extraídos para animación

~/.config/pokefetch/
├── config.json                  # Configuración
└── README.md                    # Este archivo
```

## 🎨 Fuente Recomendada

- **JetBrainsMono Nerd Font** ✅ (Ya instalado)
- Alternativas: Fira Code Nerd Font, Hack Nerd Font

Configurar en tu terminal:
```
Preferencias → Fuente → JetBrainsMono Nerd Font Mono
```

## 🔄 Pokémon Rotación

- **Intervalo**: 30 minutos
- **Al inicio**: Pokémon aleatorio de Gen 1
- **Caché**: Los GIFs se guardan para cargas futuras

## 🐧 Sistema Operativo

Optimizado para:
- **Arch Linux** ✅
- Hyprland WM
- Zsh Shell
- Pacman Package Manager

Para otros sistemas, edita `pokefetch.sh` y cambia los comandos de `pacman` a tu gestor de paquetes.

## 💡 Personalización

### Cambiar Pokémonnes Mostrados
En `waybar_pokemon_animated.py`, modifica `POKEMON_LIST`:
```python
POKEMON_LIST = list(range(1, 152))  # Gen 1
# o usa específicos:
POKEMON_LIST = [25, 94, 149, 150, 151]  # Pikachu, Gengar, Dragonite, Mewtwo, Mew
```

### Cambiar Colores
En `pokefetch.sh`, modifica las variables `C_POKEMON_*`:
```bash
C_POKEMON_RED='\033[38;5;196m'
C_POKEMON_YELLOW='\033[38;5;226m'
```

## 🆘 Solución de Problemas

### GIF no se anima en Waybar
- Verifica que `waybar` esté actualizado
- Reinicia waybar: `killall waybar; waybar &`

### Pokémon no aparece
- Verifica conexión a internet (descarga desde PokéAPI)
- Revisa permisos: `chmod 755 ~/.config/hypr/companion/`

### Información del Sistema no se muestra
- En sistemas no-Arch, instala `lsb-release`
- Edita `pokefetch.sh` con tus comandos específicos

---

**Made with ❤️ for Pokémon fans** 
Inspirado en Hyde Dotfiles: https://github.com/hyde-dotfiles
