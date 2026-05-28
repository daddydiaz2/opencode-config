#!/bin/bash
set -e

echo "🔧 Instalando OpenCode Config..."
echo ""

# 1. Directorio config
CONFIG_DIR="$HOME/.config/opencode"
BACKUP_DIR="$HOME/.config/opencode.backup.$(date +%Y%m%d%H%M%S)"

# Backup de config existente
if [ -d "$CONFIG_DIR" ]; then
    echo "📦 Backup de config anterior..."
    cp -r "$CONFIG_DIR" "$BACKUP_DIR"
    echo "  Backup en: $BACKUP_DIR"
fi

# 2. Copiar configs globales
echo "📁 Copiando configuraciones globales..."
mkdir -p "$CONFIG_DIR/agent/core"
cp -r configs/global/* "$CONFIG_DIR/"

# 3. Instalar LSPs
echo "📦 Instalando Language Servers..."
chmod +x setup-lsps.sh
./setup-lsps.sh

# 4. Crear directorios de skills globales
echo "📚 Configurando skills globales..."
mkdir -p "$CONFIG_DIR/skills/global/dotnet"
mkdir -p "$CONFIG_DIR/skills/global/csharp"
mkdir -p "$CONFIG_DIR/skills/global/frontend"
mkdir -p "$CONFIG_DIR/skills/global/python"
mkdir -p "$CONFIG_DIR/skills/global/node"

# 5. Permisos de scripts
chmod +x detect-frameworks.sh
chmod +x init-project.sh

# 6. Configurar git hooks si existe .git
if [ -d "$CONFIG_DIR/.git" ]; then
    echo "🔗 Configurando git hooks..."
fi

echo ""
echo "✅ Instalación completa!"
echo ""
echo "📋 Resumen:"
echo "  - Config: $CONFIG_DIR"
echo "  - LSPs instalados"
echo "  - Skills globales configurados"
echo ""
echo "🚀 Para inicializar un proyecto:"
echo "  cd /tu-proyecto"
echo "  ./init-project.sh"
echo ""
echo "🔍 Para auto-detectar frameworks en proyecto existente:"
echo "  ./detect-frameworks.sh /ruta/proyecto"
