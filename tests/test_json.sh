#!/bin/bash
# test_json.sh — Valida que templates/ JSONs tengan sintaxis correcta
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "━━━ JSON Validation ━━━"
FAIL=0

if ! command -v python3 &>/dev/null && ! command -v jq &>/dev/null; then
    echo "  ⚠ ni python3 ni jq disponibles. saltando."
    exit 1
fi

while IFS= read -r f; do
    # Saltar templates con placeholders (no son JSON válido por diseño)
    if grep -q '__LSP_\|{{' "$f" 2>/dev/null; then
        echo "  ⏭ ${f} (tiene placeholders, no es JSON plano)"
        continue
    fi
    
    echo -n "  → ${f} ... "
    if python3 -c "import json; json.load(open('$f'))" 2>/dev/null || \
       jq . "$f" >/dev/null 2>&1; then
        echo "OK"
    else
        echo "INVALIDO"
        python3 -c "
import json
try:
    json.load(open('$f'))
except json.JSONDecodeError as e:
    print(f'    Error: {e}')
" 2>/dev/null || true
        FAIL=1
    fi
done < <(find . -name '*.json' -not -path './.git/*' -not -path './.opencode/*' | sort)

echo ""
[ "$FAIL" -eq 0 ] && echo "✓ Todos los JSON válidos" || echo "✗ $FAIL archivo(s) inválido(s)"
exit $FAIL
