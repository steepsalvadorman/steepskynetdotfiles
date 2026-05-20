#!/bin/bash
# Fastfetch con Pokémon - Estilo Hyde Dotfiles

POKEMON_DIR="$HOME/.config/hypr/companion/pokemon_gifs"
POKEMON_FRAMES="$HOME/.config/hypr/companion/pokemon_frames"
POKEMONES=(1 4 7 25 39 54 58 60 63 66 69 72 74 77 79 81 83 84 86 88 90 92 95 96 98 100 102 104 106 108 109 111 112 113 114 115 116 118 120 122 123 124 125 126 127 128 129 131 132 133 134 135 136 137 138 140 142 143 144 145 146 147 149 150 151)

# Obtener pokémon aleatorio del actual
POKEMON_ID=$(cat /tmp/pokemon_state 2>/dev/null | grep -o '"pokemon_id": *[0-9]*' | grep -o '[0-9]*')
POKEMON_ID=${POKEMON_ID:-25}  # Fallback a Pikachu

# Obtener primer frame para mostrar
POKEMON_FRAME="$POKEMON_FRAMES/pokemon_$POKEMON_ID/frame_00.png"

# Información del sistema
OS=$(lsb_release -ds 2>/dev/null || echo "Arch Linux")
KERNEL=$(uname -r)
SHELL=$(basename $SHELL)
UPTIME=$(uptime -p | sed 's/up //')
PACKAGES=$(pacman -Q 2>/dev/null | wc -l)
CPU=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
RAM=$(free -h | awk 'NR==2 {print $3 "/" $2}')
GPU=$(lspci | grep -i vga | cut -d: -f3- | xargs)
DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2}')

# Colores
BOLD="\033[1m"
RED="\033[38;5;196m"
YELLOW="\033[38;5;226m"
CYAN="\033[38;5;51m"
GREEN="\033[38;5;46m"
MAGENTA="\033[38;5;201m"
RESET="\033[0m"

# Mostrar información con pokémon
echo -e "\n${BOLD}${RED}╔════════════════════════════════════════╗${RESET}"
echo -e "${RED}║${RESET} ${BOLD}${CYAN}🐱 Pokémon #$POKEMON_ID System Info${RESET} ${RED}║${RESET}"
echo -e "${RED}╚════════════════════════════════════════╝${RESET}\n"

# Mostrar imagen si existe
if [ -f "$POKEMON_FRAME" ]; then
    cat "$POKEMON_FRAME" 2>/dev/null || true
    echo ""
fi

# Información con colores
echo -e "${YELLOW}📦 OS${RESET}            ${GREEN}$OS${RESET}"
echo -e "${YELLOW}🐧 Kernel${RESET}        ${GREEN}$KERNEL${RESET}"
echo -e "${YELLOW}🐚 Shell${RESET}         ${GREEN}$SHELL${RESET}"
echo -e "${YELLOW}⏱️  Uptime${RESET}         ${GREEN}$UPTIME${RESET}"
echo -e "${YELLOW}📚 Packages${RESET}      ${GREEN}$PACKAGES${RESET}"
echo -e "${YELLOW}🎯 CPU${RESET}           ${GREEN}$CPU${RESET}"
echo -e "${YELLOW}💾 RAM${RESET}           ${GREEN}$RAM${RESET}"
echo -e "${YELLOW}🎮 GPU${RESET}           ${GREEN}$GPU${RESET}"
echo -e "${YELLOW}💿 Disk${RESET}          ${GREEN}$DISK${RESET}"

echo -e "\n${BOLD}${MAGENTA}✨ Powered by Pokémon${RESET}\n"
