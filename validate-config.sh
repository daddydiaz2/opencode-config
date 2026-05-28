#!/bin/bash
# validate-config.sh — Valida opencode.json: JSON syntax, binarios, paths, MCPs
set -e

CONFIG_DIR="${HOME}/.config/opencode"
CONFIG_FILE="${CONFIG_DIR}/opencode.json"
EXIT_CODE=0

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🔍 Validador de Configuración${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── 1. Check file exists ──
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ Archivo no encontrado: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}  Ejecuta install.sh primero${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Archivo existe${NC}"

# ── 2. Validate JSON syntax ──
if ! python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    if ! jq . "$CONFIG_FILE" >/dev/null 2>&1; then
        echo -e "${RED}✗ JSON inválido${NC}"
        python3 -c "
import json
try:
    json.load(open('$CONFIG_FILE'))
except json.JSONDecodeError as e:
    print(f'  Error: {e}')
" 2>/dev/null || jq . "$CONFIG_FILE" >/dev/null 2>&1 || echo "  Usa jq para debug: jq . $CONFIG_FILE"
        EXIT_CODE=1
    fi
fi
echo -e "${GREEN}✓ JSON sintaxis válida${NC}"

# ── 3. Parse and validate ──
export CONFIG_FILE
python3 << 'PYEOF'
import json, os, shutil, sys, re

# Simple markers — no ANSI codes needed from Python
OK = "[OK]"
FAIL = "[FAIL]"
WARN = "[WARN]"

exit_code = 0

with open(os.environ['CONFIG_FILE']) as f:
    config = json.load(f)

print()
print("  " + "─" * 50)
print("   Resumen de Configuracion")
print("  " + "─" * 50)
print(f"  LSPs: {len(config.get('lsp', {}))} | MCPs: {len(config.get('mcp', {}))} | Commands: {len(config.get('command', {}))}")
print()

# ── Validate LSPs ──
print("  " + "─" * 50)
print("  LSP Validation")
print("  " + "─" * 50)

lsps = config.get('lsp', {})
for name in sorted(lsps.keys()):
    lsp = lsps[name]
    cmd = lsp.get('command', [])
    if not cmd:
        print(f"  {WARN} {name}: command vacio")
        continue
    
    binary = cmd[0]
    found = shutil.which(binary) is not None
    
    # Node script path
    if binary == 'node' and len(cmd) > 1:
        found = os.path.isfile(cmd[1])
    
    status = OK if found else FAIL
    print(f"  {status} {name:<12} -> {binary}")
    if not found:
        exit_code = 1

# ── Validate MCPs ──
print()
print("  " + "─" * 50)
print("  MCP Validation")
print("  " + "─" * 50)

mcps = config.get('mcp', {})
for name in sorted(mcps.keys()):
    mcp = mcps[name]
    mcp_type = mcp.get('type', 'unknown')
    
    if mcp_type == 'local':
        cmd = mcp.get('command', [])
        if not cmd:
            print(f"  {WARN} {name}: sin command")
            continue
        binary = cmd[0]
        found = shutil.which(binary) is not None or os.path.isfile(binary)
        status = OK if found else FAIL
        print(f"  {status} {name:<20} -> {binary} (local)")
        if not found:
            exit_code = 1
    elif mcp_type == 'remote':
        url = mcp.get('url', '')
        print(f"  {OK} {name:<20} -> {url} (remote)")

# ── Validate paths in config ──
print()
print("  " + "─" * 50)
print("  Path Validation (portability check)")
print("  " + "─" * 50)

config_str = json.dumps(config)

# Check for hardcoded /home/ paths
hardcoded = re.findall(r'/home/[^/"]+', config_str)
if hardcoded:
    unique_paths = set(hardcoded)
    print(f"  {FAIL} Se encontraron {len(unique_paths)} paths hardcodeados")
    for p in sorted(unique_paths):
        print(f"     -> {p}")
    exit_code = 1
else:
    print(f"  {OK} No hay paths hardcodeados (config portatil)")

# ── Stats ──
print()
print("  " + "─" * 50)
print("  Estadisticas")
print("  " + "─" * 50)
print(f"  Modelos: {len(config.get('provider', {}).get('google', {}).get('models', {}))}")
print(f"  Formatos: {len(config.get('formatter', {}))}")

sys.exit(exit_code)
PYEOF

# Capture exit code from python
EXIT_CODE=$?

echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
    echo -e "${GREEN}✅ Configuración válida y portátil${NC}"
else
    echo -e "${RED}❌ Se encontraron problemas. Revisa arriba.${NC}"
    echo -e "${YELLOW}  Ejecuta: ./install.sh --force${NC}"
fi

exit "$EXIT_CODE"
