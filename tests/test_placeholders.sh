#!/bin/bash
# test_placeholders.sh — Verifica placeholders {{HOME}} en templates/
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "━━━ Placeholder Check ━━━"
TEMPLATES_DIR="${ROOT_DIR}/templates"

if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "  ⚠ No existe templates/. saltando."
    exit 0
fi

echo "  Verificando que templates usen {{HOME}} en vez de paths absolutos..."

# Solo verificar archivos que CONTENGAN referencias a rutas de usuario
# (tienen ${HOME} en sus paths o hacen referencia a rutas que cambian)
FAIL=0

# 1. Verificar que opencode.json template tenga {{HOME}} para filesystem MCP
#    (debe resolver el path base del filesystem)
if [ -f "${TEMPLATES_DIR}/opencode.json" ]; then
    # Buscar cualquier {{HOME}} en el template
    if grep -q '{{HOME}}' "${TEMPLATES_DIR}/opencode.json"; then
        echo "  ✓ opencode.json: usa {{HOME}} para filesystem paths"
    else
        echo "  ⚠ opencode.json: no contiene {{HOME}} (puede estar OK si no hay paths de usuario)"
    fi
fi

# 2. Verificar que openagent.md template tenga {{HOME}}
if [ -f "${TEMPLATES_DIR}/agent/core/openagent.md" ]; then
    if grep -q '{{HOME}}' "${TEMPLATES_DIR}/agent/core/openagent.md"; then
        echo "  ✓ openagent.md: usa {{HOME}}"
    else
        echo "  ⚠ openagent.md: no contiene {{HOME}} (puede estar OK)"
    fi
fi

# 3. Verificar que no haya /home/ literal en templates/
HARD_HOME=$(grep -rn '/home/' "${TEMPLATES_DIR}" 2>/dev/null || true)
if [ -n "$HARD_HOME" ]; then
    echo "  ✗ Se encontraron /home/ literales en templates/:"
    echo "$HARD_HOME"
    FAIL=1
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "✓ Placeholders OK"
else
    echo "✗ Errores de placeholders"
fi
exit $FAIL
