#!/bin/bash
# Comandos rápidos para FPS Optimization

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║             🎮 QUICK COMMANDS - FPS OPTIMIZATION              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cat << 'COMMANDS'
═════════════════════════════════════════════════════════════════════════════

📋 COMANDOS PRINCIPALES:

   1. VERIFICAR ESTADO
   ──────────────────
   $ bash ~/.config/hypr/scripts/fps-checklist.sh

   2. RECARGAR CONFIGURACIÓN
   ─────────────────────────
   $ hyprctl reload

   3. MONITOREAR GPU DURANTE GAMING
   ────────────────────────────────
   $ nvidia-smi -l 1

   4. ACTIVAR/DESACTIVAR GAMING MODE
   ─────────────────────────────────
   Presiona: Super + Alt + G

   5. ACTUALIZAR DRIVER (OPCIONAL)
   ───────────────────────────────
   $ bash ~/.config/hypr/scripts/update-nvidia-driver.sh

═════════════════════════════════════════════════════════════════════════════

🎮 WORKFLOW TÍPICO:

   1. Presiona Super+Alt+G antes de jugar
   2. Abre Diablo 4 o Marvel Rivals
   3. Disfruta de 120-144 FPS sin lag
   4. Presiona Super+Alt+G después de jugar para volver al modo normal

═════════════════════════════════════════════════════════════════════════════

📊 MONITOREAR DURANTE GAMING (en otra terminal):

   $ watch -n 1 nvidia-smi

   Debería mostrar:
   • GPU: 95-100% utilized
   • Memory: <15% used
   • Power: 200-250W
   • Temp: 70-80°C

═════════════════════════════════════════════════════════════════════════════

🔧 Si algo NO funciona:

   1. Verifica todo está ok:
      $ bash ~/.config/hypr/scripts/fps-checklist.sh

   2. Recarga hyprland:
      $ hyprctl reload

   3. Si hay error en config.jsonc:
      $ cat ~/.config/waybar/config.jsonc | python3 -m json.tool > /dev/null

═════════════════════════════════════════════════════════════════════════════

📝 ARCHIVOS IMPORTANTES:

   Config Waybar:
   ~/.config/waybar/config.jsonc

   Config Hyprland:
   ~/.config/hypr/hyprland.conf

   Config CAVA:
   ~/.config/cava/config

   Guías:
   ~/.copilot/session-state/.../FPS_OPTIMIZATION_GUIDE.md
   ~/.copilot/session-state/.../DIAGNOSTICO_DETALLADO.md

═════════════════════════════════════════════════════════════════════════════
COMMANDS

