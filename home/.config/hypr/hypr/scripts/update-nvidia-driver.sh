#!/bin/bash
# Script para actualizar driver NVIDIA de forma segura

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         🔧 ACTUALIZACIÓN SEGURA DEL DRIVER NVIDIA             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Paso 1: Actualizar todo el sistema
echo "PASO 1: Actualizando sistema..."
echo "────────────────────────────────────────────────────────────────"
sudo pacman -Syu

echo ""
echo "PASO 2: Instalando driver NVIDIA (nvidia-open)..."
echo "────────────────────────────────────────────────────────────────"
sudo pacman -S nvidia-open nvidia-utils

echo ""
echo "PASO 3: Verificando instalación..."
echo "────────────────────────────────────────────────────────────────"
nvidia-smi --query-gpu=driver_version --format=csv,noheader

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     ✅ ACTUALIZACIÓN COMPLETA                 ║"
echo "║                                                                ║"
echo "║  Para aplicar cambios, debes reiniciar:                       ║"
echo "║  $ sudo reboot                                                 ║"
echo "║                                                                ║"
echo "║  Después de reiniciar, verifica:                              ║"
echo "║  $ nvidia-smi                                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Preguntar si rebootear
read -p "¿Reiniciar ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Reiniciando en 10 segundos... (Ctrl+C para cancelar)"
    sleep 10
    sudo reboot
else
    echo "No olvides reiniciar cuando estés listo:"
    echo "$ sudo reboot"
fi

