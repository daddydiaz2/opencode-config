#!/bin/bash
# lsp-health-check.sh — Verifica salud de LSPs configurados en opencode.json
set -e

CONFIG_FILE="${HOME}/.config/opencode/opencode.json"
HEALTH_LOG="${HOME}/.config/opencode/logs/lsp-health.log"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
OK="${GREEN}✓${NC}"; FAIL="${RED}✗${NC}"; WARN="${YELLOW}⚠${NC}"

mkdir -p "$(dirname "$HEALTH_LOG")"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$HEALTH_LOG"; }

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🏥 LSP Health Check${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${FAIL} Config no encontrado: $CONFIG_FILE"
    exit 1
fi

python3 << PYEOF
import json, os, shutil, sys, subprocess, time

OK_S = "[OK]"
FAIL_S = "[FAIL]"
WARN_S = "[WARN]"

exit_code = 0

with open(os.environ['CONFIG_FILE']) as f:
    config = json.load(f)

lsps = config.get('lsp', {})
total = len(lsps)
healthy = 0
issues = []

print(f"  LSPs configurados: {total}")
print()

for name in sorted(lsps.keys()):
    lsp = lsps[name]
    cmd = lsp.get('command', [])
    if not cmd:
        print(f"  {WARN_S} {name:<15} -> command vacio")
        continue
    
    binary = cmd[0]
    ext = ', '.join(lsp.get('extensions', []))
    
    # Check binary exists
    found = shutil.which(binary) is not None
    
    # Check node script path
    if binary == 'node' and len(cmd) > 1:
        found = os.path.isfile(cmd[1])
    
    if found:
        healthy += 1
        print(f"  {OK_S} {name:<15} -> {binary:<25} [{ext}]")
    else:
        issues.append(name)
        print(f"  {FAIL_S} {name:<15} -> {binary:<25} MISSING")
        exit_code = 1

print()
print(f"  Resumen: {healthy}/{total} saludables")

if issues:
    print(f"\n  {WARN_S} Faltan {len(issues)} LSPs:")
    for name in issues:
        print(f"     - {name}")
    print(f"\n  Corre: ./setup-lsps.sh")
else:
    print(f"\n  {OK_S} {GREEN}Todos los LSPs operativos{NC if os.isatty(0) else ''}")

# Log health
with open(os.environ['HEALTH_LOG'], 'a') as log:
    log.write(f"Health check: {healthy}/{total} healthy, issues: {len(issues)}\n")

sys.exit(exit_code)
PYEOF

echo ""
echo -e "${CYAN}Log: $HEALTH_LOG${NC}"
echo ""
