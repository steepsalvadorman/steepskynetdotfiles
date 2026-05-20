#!/bin/bash
# Setup script para PokéFetch

echo "🐱 PokéFetch Setup"
echo "========================"
echo ""

# Pregunta si desea auto-ejecutar al abrir terminal
read -p "¿Ejecutar pokefetch automáticamente al abrir terminal? (s/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    # Descomenta la línea en .zshrc
    sed -i '/# pokefetch/s/# //' ~/.zshrc 2>/dev/null || sed -i '/^# pokefetch/s/^# //' ~/.zshrc 2>/dev/null
    echo "✅ PokéFetch se ejecutará al abrir terminal"
else
    echo "⏭️  Deshabilitado - usa 'pokefetch' para ejecutar manualmente"
fi

echo ""
echo "✅ Setup completado!"
echo ""
echo "Comandos disponibles:"
echo "  pokefetch     - Mostrar información del sistema con pokémon"
echo "  pf            - Alias corto"
echo ""
echo "Configuración: ~/.config/pokefetch/config.json"
echo "Documentación: ~/.config/pokefetch/README.md"
