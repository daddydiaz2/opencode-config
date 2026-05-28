#!/bin/bash
# test_install.sh — Prueba install.sh en HOME temporal, verifica output
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "━━━ Install Test (fake HOME) ━━━"

# Verificar python3
if ! command -v python3 &>/dev/null; then
    echo "  ✗ python3 necesario"
    exit 1
fi

# HOME temporal
TMP_HOME=$(mktemp -d /tmp/opencode-test-home-XXXXXX)
TARGET="${TMP_HOME}/.config/opencode"

cleanup() { rm -rf "${TMP_HOME}"; }
trap cleanup EXIT

# Ejecutar install.sh con HOME temporal y --skip-lsps
echo "  HOME=${TMP_HOME}"
echo "  Ejecutando: install.sh --skip-lsps..."
HOME="${TMP_HOME}" bash "${ROOT_DIR}/install.sh" --skip-lsps 2>&1 | sed 's/^/    /'
RC=${PIPESTATUS[0]}

# Si install.sh falló, reportar pero continuar verificando lo que generó
if [ "$RC" -ne 0 ]; then
    echo "  ⚠ install.sh exit code: ${RC} (puede ser parcial)"
fi

# ── Verificar archivos ──
echo ""
echo "━━━ Verificando archivos generados ━━━"
FAIL=0

check() {
    local path="$1"
    local label="$2"
    if [ -f "${TARGET}/${path}" ]; then
        echo "  ✓ ${label}"
    else
        echo "  ✗ ${label} -> ${TARGET}/${path}"
        FAIL=1
    fi
}

check "opencode.json"        "Config JSON"
check "agent/core/openagent.md" "Agent prompt"
check "VERSION"              "Version file"
check "LAST_INSTALL"         "Timestamp"
check "context/core/standards/code-quality.md"       "Context: code-quality"
check "context/core/standards/documentation.md"      "Context: documentation"
check "context/core/standards/test-coverage.md"      "Context: test-coverage"
check "context/core/workflows/code-review.md"        "Context: code-review"
check "context/core/workflows/task-delegation-basics.md" "Context: delegation"

# Validar JSON
if [ -f "${TARGET}/opencode.json" ]; then
    echo -n "  → JSON valido? "
    python3 -c "import json; json.load(open('${TARGET}/opencode.json')); print('OK')"
fi

# Verificar NO {{HOME}} sin resolver
echo -n "  → placeholders sin resolver? "
if grep -rq '{{HOME}}' "${TARGET}" 2>/dev/null; then
    echo "FAIL"
    grep -rn '{{HOME}}' "${TARGET}" | sed 's/^/     /'
    FAIL=1
else
    echo "OK"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "✓ Install test COMPLETO"
else
    echo "✗ Install test FALLÓ"
fi
exit $FAIL
