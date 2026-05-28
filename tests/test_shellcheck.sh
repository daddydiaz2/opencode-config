#!/bin/bash
# test_shellcheck.sh — Lint todos los .sh del repo
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "━━━ ShellCheck ━━━"
FAIL=0

if ! command -v shellcheck &>/dev/null; then
    echo "  ⚠ shellcheck no instalado. saltando."
    exit 0
fi

while IFS= read -r f; do
    echo -n "  → ${f} ... "
    if shellcheck -x -s bash "$f" 2>/dev/null; then
        echo "OK"
    else
        echo "FAIL"
        FAIL=1
    fi
done < <(find . -name '*.sh' -not -path './tests/fixtures/*' -not -path './.git/*' | sort)

exit $FAIL
