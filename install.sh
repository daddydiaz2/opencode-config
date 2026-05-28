#!/bin/bash
# install.sh — OpenCode Config Installer
# Detects system, generates configs from templates, installs dependencies
set -e

VERSION="2.0.0"
CONFIG_DIR="${HOME}/.config/opencode"
BACKUP_DIR="${HOME}/.config/opencode.backups"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

# ── Parse args ────────────────────────────────────────────────
DRY_RUN=false
FORCE=false
SKIP_LSPS=false
while [[ "$#" -gt 0 ]]; do case $1 in
    --dry-run) DRY_RUN=true ;;
    --force|-f) FORCE=true ;;
    --skip-lsps) SKIP_LSPS=true ;;
    --help|-h) echo "Usage: $0 [--dry-run] [--force] [--skip-lsps]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
esac; shift; done

echo -e "${CYAN}OpenCode Config v${VERSION} — Installer${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# ── 1. Backup ─────────────────────────────────────────────────
if [ -d "$CONFIG_DIR" ] && [ "$DRY_RUN" = false ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_PATH="$BACKUP_DIR/pre-install-$BACKUP_TIMESTAMP"
    cp -r "$CONFIG_DIR" "$BACKUP_PATH"
    echo -e "${GREEN}✓${NC} Backup creado: $BACKUP_PATH"
fi

# ── 2. System Detection ───────────────────────────────────────
echo -e "${YELLOW}🔍 Detectando sistema...${NC}"

# Paths
NODE_ROOT="$(npm root -g 2>/dev/null || echo "")"
NODE_CMD="$(which node 2>/dev/null || echo "")"
HAS_PYTHON3="$(command -v python3 >/dev/null 2>&1 && echo true || echo false)"
HAS_JQ="$(command -v jq >/dev/null 2>&1 && echo true || echo false)"

# ── LSP Resolution ────────────────────────────────────────────
# Returns JSON array string for an LSP command
resolve_lsp() {
    local bin="$1"
    local npm_path="$2"       # relative from NODE_ROOT
    local extra_args="$3"     # extra CLI args (or empty for none)
    local needs_node="${4:-true}"

    # 1) Try `which`
    local which_path
    which_path="$(which "$bin" 2>/dev/null || true)"

    if [ -n "$which_path" ]; then
        if [ "$needs_node" = "true" ] && echo "$which_path" | grep -q '\.js$'; then
            [ -n "$NODE_CMD" ] && cmd="[\"$NODE_CMD\", \"$which_path\"" || cmd="[\"$which_path\""
        else
            cmd="[\"$which_path\""
        fi
        # Append extra args if present
        [ -n "$extra_args" ] && cmd="$cmd, \"$extra_args\""
        echo "$cmd]"
        return
    fi

    # 2) Try npm root -g + relative path
    if [ -n "$NODE_ROOT" ] && [ -n "$npm_path" ]; then
        local full_path="$NODE_ROOT/$npm_path"
        if [ -f "$full_path" ]; then
            if [ "$needs_node" = "true" ]; then
                [ -n "$NODE_CMD" ] && cmd="[\"$NODE_CMD\", \"$full_path\"" || cmd="[\"$full_path\""
            else
                cmd="[\"$full_path\""
            fi
            [ -n "$extra_args" ] && cmd="$cmd, \"$extra_args\""
            echo "$cmd]"
            return
        fi
    fi

    echo null
}

echo -e "  Node: ${NODE_CMD:-not found}"
echo -e "  Python3: ${HAS_PYTHON3}"
echo -e "  jq: ${HAS_JQ}"

# Resolve each LSP
LSP_CSHARP=$(resolve_lsp "omnisharp" "" "-lsp" "false")
echo -e "  LSP csharp: ${LSP_CSHARP:-MISSING}"
LSP_RAZOR=$(resolve_lsp "html-languageserver" "vscode-html-languageserver-bin/htmlServerMain.js" "--stdio" "true")
echo -e "  LSP razor: $(echo "$LSP_RAZOR" | head -c 60)..."
LSP_HTML=$(resolve_lsp "html-languageserver" "vscode-html-languageserver-bin/htmlServerMain.js" "--stdio" "true")
echo -e "  LSP html: $(echo "$LSP_HTML" | head -c 60)..."
LSP_CSS=$(resolve_lsp "css-languageserver" "vscode-css-languageserver-bin/cssServerMain.js" "--stdio" "true")
echo -e "  LSP css: $(echo "$LSP_CSS" | head -c 60)..."
LSP_JAVASCRIPT=$(resolve_lsp "typescript-language-server" "typescript-language-server/lib/cli.mjs" "--stdio" "true")
echo -e "  LSP javascript: $(echo "$LSP_JAVASCRIPT" | head -c 60)..."
LSP_JSON=$(resolve_lsp "vscode-json-languageserver" "vscode-json-languageserver/bin/vscode-json-languageserver" "--stdio" "true")
echo -e "  LSP json: $(echo "$LSP_JSON" | head -c 60)..."
LSP_YAML=$(resolve_lsp "yaml-language-server" "yaml-language-server/bin/yaml-language-server" "--stdio" "true")
echo -e "  LSP yaml: $(echo "$LSP_YAML" | head -c 60)..."
LSP_MARKDOWN=$(resolve_lsp "remark-language-server" "remark-language-server/index.js" "--stdio" "true")
echo -e "  LSP markdown: $(echo "$LSP_MARKDOWN" | head -c 60)..."
LSP_PHP=$(resolve_lsp "intelephense" "" "" "false")
echo -e "  LSP php: ${LSP_PHP:-MISSING}"
LSP_PYTHON=$(resolve_lsp "pyright" "" "" "false")
echo -e "  LSP python: ${LSP_PYTHON:-MISSING}"
LSP_BASH=$(resolve_lsp "bash-language-server" "" "start" "false")
echo -e "  LSP bash: ${LSP_BASH:-MISSING}"

# ── MCP Detection ────────────────────────────────────────────
MCP_RADZEN=""; [ -f "${HOME}/.agents/skills/radzen-mcp/index.js" ] && MCP_RADZEN="${HOME}/.agents/skills/radzen-mcp/index.js"
MCP_MUDBLAZOR=""; [ -f "${HOME}/.agents/skills/mudblazor-mcp/index.js" ] && MCP_MUDBLAZOR="${HOME}/.agents/skills/mudblazor-mcp/index.js"
MCP_FLUENTUI=""; [ -f "${HOME}/.agents/skills/fluentui-mcp/index.js" ] && MCP_FLUENTUI="${HOME}/.agents/skills/fluentui-mcp/index.js"
MCP_LSP_MCP=""; which lsp-mcp &>/dev/null && MCP_LSP_MCP="$(which lsp-mcp)"
echo -e "\n${YELLOW}🔌 MCPs opcionales:${NC}"
echo -e "  radzen-blazor: $([ -n "$MCP_RADZEN" ] && echo '✓' || echo '✗')"
echo -e "  mudblazor: $([ -n "$MCP_MUDBLAZOR" ] && echo '✓' || echo '✗')"
echo -e "  fluentui: $([ -n "$MCP_FLUENTUI" ] && echo '✓' || echo '✗')"
echo -e "  lsp-mcp: $([ -n "$MCP_LSP_MCP" ] && echo '✓' || echo '✗')"

if [ "$DRY_RUN" = true ]; then
    echo -e "\n${YELLOW}--dry-run: No se escribieron archivos${NC}"
    exit 0
fi

# ── 3. Generate opencode.json ─────────────────────────────────
echo -e "\n${YELLOW}📝 Generando configs...${NC}"

mkdir -p "$CONFIG_DIR/agent/core"
mkdir -p "$CONFIG_DIR/logs"

if [ "$HAS_PYTHON3" = "true" ]; then
    # Export all detection vars for Python heredoc
    export CONFIG_DIR SCRIPT_DIR HOME
    export LSP_CSHARP LSP_RAZOR LSP_HTML LSP_CSS LSP_JAVASCRIPT LSP_JSON LSP_YAML LSP_MARKDOWN LSP_PHP LSP_PYTHON LSP_BASH
    export MCP_RADZEN MCP_MUDBLAZOR MCP_FLUENTUI MCP_LSP_MCP

    # ── Python processor (preferred) ──
    python3 << PYEOF
import json, os, sys

HOME = os.environ['HOME']
CONFIG_DIR = os.environ['CONFIG_DIR']
SCRIPT_DIR = os.environ['SCRIPT_DIR']

def load_json_or_null(val):
    try:
        return json.loads(val) if val and val != 'null' else None
    except:
        return None

# ── Read template ──
with open(f'{SCRIPT_DIR}/templates/opencode.json') as f:
    content = f.read()

# ── LSP command resolution ──
lsp_replacements = {}
for key in ['CSHARP', 'RAZOR', 'HTML', 'CSS', 'JAVASCRIPT', 'JSON', 'YAML', 'MARKDOWN', 'PHP', 'PYTHON', 'BASH']:
    val = os.environ.get(f'LSP_{key}', 'null')
    resolved = load_json_or_null(val)
    if resolved:
        lsp_replacements[key] = resolved  # key = 'CSHARP' (match.group(1) from regex)

def replace_lsp_placeholders(content, replacements):
    import re
    def replacer(match):
        key = match.group(1)
        if key in replacements:
            return json.dumps(replacements[key])
        return match.group(0)
    return re.sub(r'__LSP_(\w+)__', replacer, content)

content = replace_lsp_placeholders(content, lsp_replacements)

# Remove remaining unresolved placeholders (set to null)
import re
content = re.sub(r'__\w+__', 'null', content)

# ── Parse JSON ──
config = json.loads(content)

# ── Add conditional MCPs ──
mcp_paths = {
    'radzen-blazor': os.environ.get('MCP_RADZEN', ''),
    'mudblazor': os.environ.get('MCP_MUDBLAZOR', ''),
    'fluentui': os.environ.get('MCP_FLUENTUI', ''),
}
for name, path in mcp_paths.items():
    if path:
        config['mcp'][name] = {
            "type": "local",
            "command": ["node", path],
            "enabled": True
        }

# Add lsp-mcp fallback if available
lsp_mcp_path = os.environ.get('MCP_LSP_MCP', '')
if lsp_mcp_path:
    if 'csharp' in config.get('lsp', {}) and 'lsp-mcp' not in config.get('mcp', {}):
        config['mcp']['lsp-mcp'] = {
            "type": "local", 
            "command": ["lsp-mcp"],
            "enabled": True,
            "timeout": 30000,
            "description": "LSP fallback via lsp-mcp"
        }

# ── Inject config descriptions ──
for name, lsp in config.get('lsp', {}).items():
    ext_str = ', '.join(lsp.get('extensions', []))
    lsp['description'] = f"LSP para {ext_str}"

# ── Write ──
os.makedirs(f'{CONFIG_DIR}', exist_ok=True)
with open(f'{CONFIG_DIR}/opencode.json', 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write('\n')

print(f'  ✓ opencode.json generado ({len(config.get("lsp", {}))} LSPs, {len(config.get("mcp", {}))} MCPs)')
PYEOF

else
    # ── jq fallback ──
    echo -e "${YELLOW}  ⚠ Python3 no disponible, usando jq fallback${NC}"
    # Replace placeholders and validate
    sed "s|{{HOME}}|${HOME}|g; s|__LSP_[A-Z_]*__|null|g" "$SCRIPT_DIR/templates/opencode.json" > "/tmp/opencode-fallback.json"
    if jq . "/tmp/opencode-fallback.json" > "$CONFIG_DIR/opencode.json" 2>/dev/null; then
        echo -e "  ✓ opencode.json (fallback jq, LSPs a null)"
    else
        echo -e "  ${RED}✗ Fallback falló. Copiando template raw.${NC}"
        cp "/tmp/opencode-fallback.json" "$CONFIG_DIR/opencode.json"
    fi
    rm -f "/tmp/opencode-fallback.json"
fi

# ── 4. Generate openagent.md ──────────────────────────────────
echo -e "  Generando openagent.md..."
sed "s|{{HOME}}|${HOME}|g" "$SCRIPT_DIR/templates/agent/core/openagent.md" > "$CONFIG_DIR/agent/core/openagent.md"
echo -e "  ✓ openagent.md generado"

# ── 4b. Install context files ─────────────────────────────────
echo -e "  Instalando context files..."
CONTEXT_SRC="$SCRIPT_DIR/templates/context"
if [ -d "$CONTEXT_SRC" ]; then
    find "$CONTEXT_SRC" -name "*.md" | while read f; do
        rel="${f#$CONTEXT_SRC/}"
        mkdir -p "$CONFIG_DIR/context/$(dirname "$rel")"
        sed "s|{{HOME}}|${HOME}|g" "$f" > "$CONFIG_DIR/context/$rel"
    done
    echo -e "  ✓ Context files instalados ($(find "$CONTEXT_SRC" -name '*.md' | wc -l) archivos)"
else
    echo -e "  ${YELLOW}⚠ No se encontraron templates de context${NC}"
fi

# ── 5. Validate ───────────────────────────────────────────────
echo -e "\n${YELLOW}🔍 Validando config...${NC}"
if [ -f "$CONFIG_DIR/opencode.json" ]; then
    if python3 -c "import json; json.load(open('$CONFIG_DIR/opencode.json')); print('  ✓ JSON válido')" 2>/dev/null || \
       jq . "$CONFIG_DIR/opencode.json" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Config válida${NC}"
    else
        echo -e "${RED}  ✗ JSON inválido!${NC}"
        exit 1
    fi
fi

# ── 6. Install LSPs ───────────────────────────────────────────
if [ "$SKIP_LSPS" = false ]; then
    echo -e "\n${YELLOW}📦 Instalando LSPs faltantes...${NC}"
    if [ -x "$SCRIPT_DIR/setup-lsps.sh" ]; then
        bash "$SCRIPT_DIR/setup-lsps.sh" || echo -e "  ${YELLOW}  ⚠ setup-lsps.sh falló (no crítico, algunos LSPs pueden faltar)${NC}"
    else
        echo -e "  ⚠ setup-lsps.sh no encontrado"
    fi
else
    echo -e "\n${YELLOW}⏭ Instalación de LSPs saltada (--skip-lsps)${NC}"
fi

# ── 7. Create version file ────────────────────────────────────
echo "$VERSION" > "$CONFIG_DIR/VERSION"
echo "$BACKUP_TIMESTAMP" > "$CONFIG_DIR/LAST_INSTALL"

# ── 8. Summary ────────────────────────────────────────────────
echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ OpenCode Config v${VERSION} instalado${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Config: ${CYAN}${CONFIG_DIR}${NC}"
echo -e "  Backup: ${CYAN}${BACKUP_DIR}/pre-install-${BACKUP_TIMESTAMP}${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos recomendados:${NC}"
echo -e "  1. Revisa: ${CYAN}${CONFIG_DIR}/opencode.json${NC}"
echo -e "  2. Corre:  ${CYAN}opencode /tu-proyecto${NC}"
echo -e "  3. Si algo falla: ${CYAN}./opencode-config-manager.sh restore${NC}"
echo ""
