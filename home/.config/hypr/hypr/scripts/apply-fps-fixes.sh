#!/bin/bash
# Script automático para aplicar optimizaciones de FPS
# Uso: bash ~/.config/hypr/scripts/apply-fps-fixes.sh

set -e

echo "🎮 === APLICANDO OPTIMIZACIONES DE FPS ==="
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para hacer backup
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✓${NC} Backup creado: ${file}.backup"
    fi
}

# ==========================================
# 1. APLICAR FIXES A HYPRLAND.CONF
# ==========================================
echo -e "${YELLOW}1️⃣  Optimizando hyprland.conf...${NC}"

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
backup_file "$HYPR_CONF"

# Fix 1: Cambiar direct_scanout a true
if grep -q "direct_scanout = false" "$HYPR_CONF"; then
    sed -i 's/direct_scanout = false/direct_scanout = true/' "$HYPR_CONF"
    echo -e "${GREEN}✓${NC} direct_scanout activado"
fi

# Fix 2: Agregar gaming mode hotkey si no existe
if ! grep -q "bind = \$mainMod ALT, G, exec" "$HYPR_CONF"; then
    # Agregar antes de la última línea del archivo
    sed -i '$ i bind = $mainMod ALT, G, exec, ~/.config/hypr/scripts/gaming-mode.sh' "$HYPR_CONF"
    echo -e "${GREEN}✓${NC} Hotkey Gaming Mode agregado (Super+Alt+G)"
fi

# Fix 3: Optimizar VRR
if grep -q "misc {" "$HYPR_CONF"; then
    if ! grep -q "vrr = 2" "$HYPR_CONF"; then
        sed -i '/misc {/,/}/s/vrr = 1/vrr = 2/' "$HYPR_CONF"
        echo -e "${GREEN}✓${NC} VRR optimizado para fullscreen"
    fi
fi

echo ""

# ==========================================
# 2. APLICAR FIXES A WAYBAR CONFIG
# ==========================================
echo -e "${YELLOW}2️⃣  Optimizando waybar config.jsonc...${NC}"

WAYBAR_CONF="$HOME/.config/waybar/config.jsonc"
backup_file "$WAYBAR_CONF"

# Fix intervals - CPU
sed -i 's/"cpu": {/"cpu": {\n        "format": "󰻠 {usage}%",/' "$WAYBAR_CONF" 2>/dev/null || true
sed -i '/"cpu": {/,/}/ s/"interval": 2,/"interval": 10,/' "$WAYBAR_CONF"
echo -e "${GREEN}✓${NC} CPU interval: 2s → 10s"

# Fix intervals - Memory
sed -i '/"memory": {/,/}/ s/"interval": 5,/"interval": 15,/' "$WAYBAR_CONF"
echo -e "${GREEN}✓${NC} Memory interval: 5s → 15s"

# Fix intervals - Temperature
sed -i '/"temperature": {/,/}/ s/"interval": 5,/"interval": 20,/' "$WAYBAR_CONF"
echo -e "${GREEN}✓${NC} Temperature interval: 5s → 20s"

# Fix intervals - Network
sed -i '/"network": {/,/}/ s/"interval": 10,/"interval": 30,/' "$WAYBAR_CONF"
echo -e "${GREEN}✓${NC} Network interval: 10s → 30s"

# Fix intervals - Docker
sed -i '/"custom\/docker": {/,/}/ s/"interval": 5,/"interval": 60,/' "$WAYBAR_CONF"
echo -e "${GREEN}✓${NC} Docker interval: 5s → 60s"

echo ""

# ==========================================
# 3. APLICAR FIXES A CAVA CONFIG
# ==========================================
echo -e "${YELLOW}3️⃣  Optimizando cava config...${NC}"

CAVA_CONF="$HOME/.config/cava/config"
backup_file "$CAVA_CONF"

if [ -f "$CAVA_CONF" ]; then
    sed -i 's/framerate = 60/framerate = 15/' "$CAVA_CONF"
    sed -i 's/framerate = 20/framerate = 15/' "$CAVA_CONF"
    echo -e "${GREEN}✓${NC} CAVA framerate: 60/20 → 15"
fi

echo ""

# ==========================================
# RESUMEN
# ==========================================
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ OPTIMIZACIONES APLICADAS EXITOSAMENTE${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo "📝 Cambios realizados:"
echo "   • Direct scanout: ACTIVADO"
echo "   • Gaming Mode Hotkey: AGREGADO (Super+Alt+G)"
echo "   • Waybar intervals: AUMENTADOS"
echo "   • CAVA framerate: REDUCIDO (60/20 → 15)"
echo ""
echo "🔄 Próximos pasos:"
echo "   1. Recarga configuración: hyprctl reload"
echo "   2. O reinicia Hyprland (logout/login)"
echo "   3. CRÍTICO: Actualiza driver NVIDIA"
echo "      $ sudo pacman -Syu && sudo pacman -S nvidia"
echo ""
echo "🎮 Para modo gaming:"
echo "   Presiona: Super+Alt+G"
echo ""

