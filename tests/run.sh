#!/bin/bash
# run.sh — Test runner para opencode-config
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
START_TIME=$(date +%s%N)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  OpenCode Config — Test Suite${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

SKIP_SLOW=false
[[ "${1:-}" == "--quick" ]] && SKIP_SLOW=true
[[ "${CI:-}" == "true" ]] && echo -e "  ${YELLOW}CI detected${NC}\n"

TOTAL=0
PASSED=0
FAILED=0

for f in "$TESTS_DIR"/test_*.sh; do
    [ -f "$f" ] || continue
    
    name="$(basename "$f" .sh)"
    
    # Saltar install en modo quick
    if [ "$SKIP_SLOW" = true ] && [ "$name" = "test_install" ]; then
        echo -e "  ${YELLOW}⏭  ${name} (saltado --quick)${NC}"
        continue
    fi
    
    echo -e "  ${CYAN}[${name}]${NC}"
    TOTAL=$((TOTAL + 1))
    
    set +e
    bash "$f"
    rc=$?
    set -e
    
    if [ "$rc" -eq 0 ]; then
        echo -e "  ${GREEN}✓ ${name} OK${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}✗ ${name} FAIL (exit: ${rc})${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

END_TIME=$(date +%s%N)
DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
echo -e "  Duration: ${DURATION_MS}ms"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

exit $FAILED
