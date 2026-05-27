#!/usr/bin/env bash
# 🐱 PokéFetch - Pokémon System Info (Estilo Hyde Dotfiles)

set -euo pipefail

# Configuración de rutas
STATE_FILE="/tmp/pokemon_state"
POKEMON_FRAMES="$HOME/.config/hypr/companion/pokemon_frames"

# Obtener pokémon actual
POKEMON_ID=$(cat "$STATE_FILE" 2>/dev/null | grep -o '"pokemon_id": *[0-9]*' | grep -o '[0-9]*' || echo "25")
POKEMON_FRAME="$POKEMON_FRAMES/pokemon_$POKEMON_ID/frame_00.png"

# Colores ANSI - Estilo Hyde (Brillantes y Elegantes)
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_RED='\033[38;5;204m'       # Rojo brillante/Coral
C_YELLOW='\033[38;5;220m'    # Amarillo dorado
C_GREEN='\033[38;5;114m'     # Verde esmeralda suave
C_CYAN='\033[38;5;73m'       # Cyan/Turquesa
C_MAGENTA='\033[38;5;182m'   # Lavanda/Pink
C_BLUE='\033[38;5;111m'      # Azul pastel
C_WHITE='\033[97m'           # Blanco brillante
C_GRAY='\033[38;5;244m'      # Gris medio

# Obtener CPU
get_cpu() {
    local cpu
    cpu=$(lscpu 2>/dev/null | grep "Model name" | cut -d: -f2 | xargs 2>/dev/null || echo "")
    if [ -z "$cpu" ]; then
        cpu=$(cat /proc/cpuinfo 2>/dev/null | grep "model name" | head -1 | cut -d: -f2 | xargs 2>/dev/null || echo "Unknown CPU")
    fi
    # Limpiar detalles innecesarios para que sea corto
    echo "$cpu" | sed -E 's/\(R\)|\(TM\)//g' | cut -c1-38
}

# Obtener información del sistema
get_system_info() {
    local os kernel shell uptime packages cpu ram gpu disk wm
    os=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Arch Linux")
    kernel=$(uname -r)
    shell=$(basename "$SHELL")
    uptime=$(uptime -p 2>/dev/null | sed 's/up //')
    packages=$(pacman -Q 2>/dev/null | wc -l || echo "N/A")
    cpu=$(get_cpu)
    ram=$(free -h 2>/dev/null | awk 'NR==2 {printf "%s / %s", $3, $2}' || echo "N/A")
    gpu=$(lspci 2>/dev/null | grep -i vga | cut -d: -f3- | xargs | sed 's/ Corporation//g' | cut -c1-35 || echo "Unknown GPU")
    disk=$(df -h / 2>/dev/null | awk 'NR==2 {printf "%s / %s", $3, $2}' || echo "N/A")
    wm=$(echo "${XDG_CURRENT_DESKTOP:-Hyprland}" | sed 's/.*://')
    
    echo "$os|$kernel|$shell|$uptime|$packages|$cpu|$ram|$gpu|$disk|$wm"
}

# Parsear información
IFS='|' read -r OS KERNEL SHELL UPTIME PACKAGES CPU RAM GPU DISK WM <<< "$(get_system_info)"

# Helper para imprimir en dos columnas. El margen izquierdo de 28 espacios deja lugar para la imagen de Kitty
print_info() {
    local label="$1"
    local value="$2"
    local color="$3"
    printf "                            ${C_BOLD}${color}%-10s${C_RESET}  ${C_WHITE}%s${C_RESET}\n" "$label" "$value"
}

main() {
    # Limpiar pantalla y dar un pequeño respiro arriba
    clear
    echo ""
    
    # Dibujar la imagen del Pokémon con Kitty icat si está disponible y en Kitty terminal
    # La colocamos en la esquina (24 columnas de ancho, 10 filas de alto, en la columna 0 de la fila 1)
    if [ -f "$POKEMON_FRAME" ] && [ "${TERM:-}" = "xterm-kitty" ]; then
        # Elimina imágenes previas en la misma región y dibuja la nueva
        kitty +kitten icat --place 24x10@0x1 --silent --transfer-mode file "$POKEMON_FRAME" 2>/dev/null || \
        kitty +kitten icat --place 24x10@0x1 --silent "$POKEMON_FRAME" 2>/dev/null || true
    fi
    
    # Imprimir información a la derecha (comienza después de 28 espacios de margen)
    printf "                            ${C_BOLD}${C_RED}Steep Salvador${C_RESET}\n"
    printf "                            ${C_GRAY}---------------------------${C_RESET}\n"
    
    print_info "OS" "$OS" "$C_CYAN"
    print_info "Kernel" "$KERNEL" "$C_CYAN"
    print_info "Uptime" "$UPTIME" "$C_GREEN"
    print_info "Packages" "$PACKAGES" "$C_GREEN"
    print_info "Shell" "$SHELL" "$C_MAGENTA"
    print_info "WM" "$WM" "$C_MAGENTA"
    print_info "CPU" "$CPU" "$C_YELLOW"
    print_info "GPU" "$GPU" "$C_YELLOW"
    print_info "Memory" "$RAM" "$C_BLUE"
    print_info "Disk" "$DISK" "$C_BLUE"
    
    # Imprimir la paleta de colores estilo neofetch/fastfetch al final
    printf "\n                            "
    for c in {40..47}; do
        printf "\e[${c}m   \e[0m"
    done
    printf "\n"
    
    # Línea decorativa final para asegurar que el prompt no pise la imagen
    echo ""
    echo ""
}

main
