#!/bin/bash
# init-project.sh — Inicializa OpenCode en un proyecto
# Crea .opencode/, detecta stack, instala skills
set -e

PROJECT_DIR="${1:-$(pwd)}"
OPENCODE_DIR="$PROJECT_DIR/.opencode"

echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;36m  🚀 Inicializando OpenCode en: $PROJECT_DIR\033[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

# 1. Crear estructura
mkdir -p "$OPENCODE_DIR/skills"

# 2. Detectar frameworks
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/detect-frameworks.sh" ]; then
    echo -e "\033[1;33m🔍 Detectando stack...\033[0m"
    bash "$SCRIPT_DIR/detect-frameworks.sh" "$PROJECT_DIR"
fi

# 3. Ejecutar autoskills
if command -v npx &>/dev/null; then
    echo ""
    echo -e "\033[1;33m📦 Ejecutando npx autoskills...\033[0m"
    cd "$PROJECT_DIR"
    if npx autoskills --yes 2>&1; then
        echo -e "  \033[0;32m✓ autoskills completado\033[0m"
    else
        echo -e "  \033[0;33m⚠ autoskills falló (no crítico)\033[0m"
    fi
fi

# 4. Crear AGENTS.md si no existe
if [ ! -f "$PROJECT_DIR/AGENTS.md" ]; then
    echo ""
    echo -e "\033[1;33m📝 Creando AGENTS.md...\033[0m"
    cat > "$PROJECT_DIR/AGENTS.md" << 'AGENTSEOF'
# AGENTS.md — Contexto de este proyecto

## Idioma
- Trabajar en español (análisis, código, docs, commits)

## Stack
- [Detectado automáticamente — revisa .opencode/analysis.json]

## Build
- [Agrega comandos de build/test aquí]
AGENTSEOF
    echo -e "  \033[0;32m✓ AGENTS.md creado\033[0m"
fi

# Summary
echo ""
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[0;32m  ✅ Proyecto inicializado\033[0m"
echo ""
echo "  📁 $OPENCODE_DIR/"
echo "    ├── skills/      (skills del proyecto)"
echo "    └── analysis.json (framework detection)"
echo ""
echo "  Para empezar: opencode $PROJECT_DIR"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
