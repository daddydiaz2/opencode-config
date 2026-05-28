#!/bin/bash
# test_portability.sh — Verifica 0 paths hardcodeados en templates/
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "━━━ Portability Check ━━━"
TEMPLATES_DIR="${ROOT_DIR}/templates"

if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "  ⚠ No existe templates/. saltando."
    exit 0
fi

# Buscar /home/ en templates/ (debería ser 0)
HARDCODED=$(grep -rn '/home/' "$TEMPLATES_DIR" 2>/dev/null || true)

if [ -n "$HARDCODED" ]; then
    echo "  ✗ Se encontraron paths hardcodeados en templates/:"
    echo "$HARDCODED" | while IFS= read -r line; do
        echo "     $line"
    done
    exit 1
fi

echo "  ✓ 0 paths hardcodeados en templates/"
echo ""

# Verificar que NO hay /home/ en .sh scripts del root (excepto fixtures/)
echo "━━━ Script Portability ━━━"
ROOT_SCRIPTS=$(grep -rn '/home/' . --include='*.sh' \
    --exclude-dir='.git' \
    --exclude-dir='tests/fixtures' 2>/dev/null || true)

if [ -n "$ROOT_SCRIPTS" ]; then
    echo "  ⚠ scripts con /home/ (pueden ser válidos si usan \${HOME}):"
    echo "$ROOT_SCRIPTS" | while IFS= read -r line; do
        echo "     $line"
    done
    echo "  (estos son válidos si usan \${HOME} en lugar del path literal)"
fi

exit 0
