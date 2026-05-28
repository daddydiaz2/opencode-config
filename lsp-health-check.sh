#!/bin/bash
set -e

# LSP Health Monitor
# Checks all configured LSPs and reports status

CONFIG_DIR="$HOME/.config/opencode"
OPENCODE_JSON="$CONFIG_DIR/opencode.json"
HEALTH_LOG="$CONFIG_DIR/logs/lsp-health.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

mkdir -p "$CONFIG_DIR/logs"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$HEALTH_LOG"
}

check_lsp() {
    local name="$1"
    local command="$2"
    local extensions="$3"
    
    echo -n "Checking $name... "
    
    # Check if binary exists
    if ! command -v "$command" >/dev/null 2>&1; then
        echo -e "${RED}✗ Binary not found: $command${NC}"
        log "ERROR: $name - Binary not found: $command"
        return 1
    fi
    
    # Test initialization with timeout
    local test_result
    if timeout 10 bash -c "echo '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"processId\":$$,\"rootUri\":\"file://$(pwd)\",\"capabilities\":{},\"clientInfo\":{\"name\":\"health-check\",\"version\":\"1.0\"},\"protocolVersion\":\"2024-11-05\"}}' | $command --stdio >/dev/null 2>&1 &" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
        log "OK: $name - Responding"
        return 0
    else
        echo -e "${YELLOW}⚠ Warning: Slow or no response${NC}"
        log "WARN: $name - Slow/no response"
        return 1
    fi
}

# Parse opencode.json and check each LSP
echo -e "${GREEN}🏥 LSP Health Check${NC}"
echo "===================="
echo ""

if [ ! -f "$OPENCODE_JSON" ]; then
    echo -e "${RED}✗ Config not found: $OPENCODE_JSON${NC}"
    exit 1
fi

# Extract LSPs from config and check each one
python3 << PYTHON_SCRIPT
import json
import subprocess
import sys

with open("$OPENCODE_JSON") as f:
    config = json.load(f)

lsps = config.get("lsp", {})
total = len(lsps)
healthy = 0
issues = []

for name, lsp_config in lsps.items():
    command = lsp_config.get("command", [""])[0]
    extensions = lsp_config.get("extensions", [])
    
    # Check if command exists
    result = subprocess.run(["which", command], capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"  ✓ {name:<15} ({', '.join(extensions)})")
        healthy += 1
    else:
        print(f"  ✗ {name:<15} MISSING: {command}")
        issues.append(name)

print(f"\n{healthy}/{total} LSPs healthy")

if issues:
    print(f"\n⚠️  Missing LSPs: {', '.join(issues)}")
    print("Run: ./setup-lsps.sh")
    sys.exit(1)
else:
    print("\n✅ All LSPs operational!")
    sys.exit(0)
PYTHON_SCRIPT
