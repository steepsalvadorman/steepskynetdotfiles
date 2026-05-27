#!/bin/bash
# 🎮 FPS Optimization Checklist

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        🎮 FPS OPTIMIZATION - VERIFICATION CHECKLIST           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

checks_passed=0
checks_failed=0

check() {
    local name=$1
    local cmd=$2
    
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} $name"
        ((checks_failed++))
    fi
}

echo "VERIFICACIONES DEL SISTEMA"
echo "═════════════════════════════════════════════════════════════════"
echo ""

echo "1. DRIVER NVIDIA:"
nvidia_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null)
if [ -n "$nvidia_version" ]; then
    major_version=$(echo $nvidia_version | cut -d. -f1)
    if [ "$major_version" -ge 575 ]; then
        echo -e "${GREEN}✓${NC} Driver NVIDIA: $nvidia_version (OPTIMIZADO)"
        ((checks_passed++))
    else
        echo -e "${RED}✗${NC} Driver NVIDIA: $nvidia_version (DESACTUALIZADO - actualizar a 575+)"
        ((checks_failed++))
    fi
else
    echo -e "${RED}✗${NC} Driver NVIDIA: No detectado"
    ((checks_failed++))
fi
echo ""

echo "2. CONFIGURACIÓN HYPRLAND:"
check "direct_scanout activado" "grep -q 'direct_scanout = true' ~/.config/hypr/hyprland.conf"
check "Gaming Mode hotkey configurado" "grep -q 'bind = \$mainMod ALT, G' ~/.config/hypr/hyprland.conf"
check "Xwayland optimizado/desactivado" "grep -q 'xwayland' ~/.config/hypr/hyprland.conf"
echo ""

echo "3. CONFIGURACIÓN WAYBAR:"
check "CPU interval optimizado" "grep -q '\"interval\": 10' ~/.config/waybar/config.jsonc && grep -B3 'interval\": 10' ~/.config/waybar/config.jsonc | grep -q '\"cpu\"'"
check "Memory interval optimizado" "grep -q '\"interval\": 15' ~/.config/waybar/config.jsonc"
check "Network interval optimizado" "grep -q '\"interval\": 30' ~/.config/waybar/config.jsonc"
echo ""

echo "4. CONFIGURACIÓN CAVA:"
check "CAVA framerate optimizado" "grep -q 'framerate = 15' ~/.config/cava/config"
echo ""

echo "5. ARCHIVOS DE GAMING MODE:"
check "Script gaming-mode.sh existe" "[ -x ~/.config/hypr/scripts/gaming-mode.sh ]"
check "Script apply-fps-fixes.sh existe" "[ -x ~/.config/hypr/scripts/apply-fps-fixes.sh ]"
check "Perfil gaming.conf existe" "[ -f ~/.config/hypr/profiles/gaming.conf ]"
echo ""

echo "═════════════════════════════════════════════════════════════════"
echo ""
echo "RESUMEN:"
echo -e "  ${GREEN}Checks pasados: $checks_passed${NC}"
echo -e "  ${RED}Checks fallidos: $checks_failed${NC}"
echo ""

if [ $checks_failed -eq 0 ]; then
    echo -e "${GREEN}✓ TODAS LAS OPTIMIZACIONES ESTÁN CONFIGURADAS${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "  1. Recargar Hyprland: hyprctl reload"
    echo "  2. IMPORTANTE: Actualizar driver si aún no lo has hecho"
    echo "  3. Presiona Super+Alt+G ANTES de jugar para modo gaming"
else
    echo -e "${YELLOW}⚠️  Aún hay optimizaciones por aplicar${NC}"
    echo ""
    echo "Para aplicarlas automáticamente:"
    echo "  $ bash ~/.config/hypr/scripts/apply-fps-fixes.sh"
fi
echo ""

