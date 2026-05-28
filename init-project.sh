#!/bin/bash
set -e

PROJECT_DIR="${1:-$(pwd)}"
OPENCODE_DIR="$PROJECT_DIR/.opencode"

echo "🚀 Inicializando OpenCode en: $PROJECT_DIR"
echo ""

# 1. Crear directorio .opencode
echo "📁 Creando estructura .opencode..."
mkdir -p "$OPENCODE_DIR/skills"
mkdir -p "$OPENCODE_DIR/mcp"

# 2. Detectar frameworks
echo "🔍 Detectando stack..."
if [ -x "$(dirname "$0")/detect-frameworks.sh" ]; then
    "$(dirname "$0")/detect-frameworks.sh" "$PROJECT_DIR"
else
    ./detect-frameworks.sh "$PROJECT_DIR"
fi

# 3. Copiar template de MCP si existe
if [ -d "configs/project-template/.opencode" ]; then
    echo "📋 Copiando template MCP..."
    cp configs/project-template/.opencode/mcp.json "$OPENCODE_DIR/" 2>/dev/null || true
fi

# 4. Ejecutar autoskills si está disponible
if command -v npx &> /dev/null; then
    echo ""
    echo "📦 Ejecutando npx autoskills..."
    cd "$PROJECT_DIR"
    if npx autoskills --yes 2>&1; then
        echo "  ✅ autoskills completado"
    else
        echo "  ⚠️ autoskills no disponible o falló (no es crítico)"
    fi
else
    echo "  ⚠️ npx no encontrado, omitiendo autoskills"
fi

# 5. Resumen
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Proyecto inicializado exitosamente!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📁 Estructura creada:"
echo "  $OPENCODE_DIR/"
echo "    ├── skills/          (skills del proyecto)"
echo "    └── mcp.json        (config MCP del proyecto)"
echo ""
echo "🔧 Skills instalados:"
if [ -d "$PROJECT_DIR/.claude/skills" ]; then
    ls -1 "$PROJECT_DIR/.claude/skills/" 2>/dev/null | sed 's/^/  - /' || echo "  (ninguno)"
else
    echo "  (ninguno - ejecuta npx autoskills manualmente)"
fi

echo ""
echo "🚀 Para empezar a trabajar:"
echo "  cd $PROJECT_DIR"
echo "  opencode"
echo ""
