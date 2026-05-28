#!/bin/bash
# setup-lsps.sh — Instala todos los Language Servers referenciados en opencode.json
set -e

echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;33m  📦 Instalando Language Servers\033[0m"
echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

INSTALLED=0
MISSING=0
FAILED=0

check_cmd() {
    if command -v "$1" &>/dev/null; then
        echo -e "  \033[0;32m✓\033[0m $1 (ya instalado)"
        ((INSTALLED++))
        return 0
    fi
    return 1
}

install_npm() {
    local pkg="$1"
    local bin="${2:-$1}"
    
    if check_cmd "$bin"; then return 0; fi
    
    echo -n "  📥 Instalando $pkg... "
    if npm install -g "$pkg" &>/dev/null; then
        echo -e "\033[0;32mOK\033[0m"
        ((INSTALLED++))
    else
        echo -e "\033[0;31mFALLÓ\033[0m"
        ((FAILED++))
    fi
}

install_npm_path() {
    # Install npm package but check by path, not global bin
    local pkg="$1"
    local path="${2}"
    local NODE_ROOT
    NODE_ROOT="$(npm root -g 2>/dev/null || true)"
    
    if [ -n "$NODE_ROOT" ] && [ -f "$NODE_ROOT/$path" ]; then
        echo -e "  \033[0;32m✓\033[0m $pkg (ya instalado en $NODE_ROOT/$path)"
        ((INSTALLED++))
        return 0
    fi
    
    echo -n "  📥 Instalando $pkg... "
    if npm install -g "$pkg" &>/dev/null; then
        if [ -f "$(npm root -g)/$path" ]; then
            echo -e "\033[0;32mOK\033[0m"
            ((INSTALLED++))
        else
            echo -e "\033[0;33m⚠ Instalado pero no encontrado en ruta esperada\033[0m"
            ((INSTALLED++))
        fi
    else
        echo -e "\033[0;31mFALLÓ\033[0m"
        ((FAILED++))
    fi
}

# ── Verificar npm ─────────────────────────────────────────
if ! command -v npm &>/dev/null; then
    echo -e "\033[0;31m✗ npm no encontrado. Instala Node.js primero.\033[0m"
    echo "  https://nodejs.org/"
    exit 1
fi
echo -e "\033[0;36m  npm: $(npm --version)\033[0m\n"

# ── 1. C# (OmniSharp) ─────────────────────────────────────
echo -e "\n\033[1;34m. NET / C#\033[0m"
if check_cmd "omnisharp"; then true; else
    echo -n "  📥 Instalando omnisharp... "
    if dotnet tool install --global Omnisharp --version latest 2>/dev/null; then
        echo -e "\033[0;32mOK\033[0m"
        ((INSTALLED++))
    else
        # Try via npm or download
        if command -v dotnet &>/dev/null; then
            echo -e "\033[0;33m⚠ dotnet disponible pero omnisharp falló. Prueba manual:\033[0m"
            echo "    dotnet tool install --global Omnisharp"
        else
            echo -e "\033[0;33m⚠ dotnet SDK no disponible. OmniSharp no instalado.\033[0m"
        fi
        ((MISSING++))
    fi
fi

# ── 2-4. LSPs vscode (HTML/CSS/JSON) ──────────────────────
echo -e "\n\033[1;34mWeb (HTML / CSS / JSON)\033[0m"
install_npm_path "vscode-html-languageserver-bin" "vscode-html-languageserver-bin/html-server.js"
install_npm_path "vscode-css-languageserver-bin" "vscode-css-languageserver-bin/css-server.js"
install_npm_path "vscode-json-languageserver" "vscode-json-languageserver/bin/vscode-json-languageserver"

# ── 5. TypeScript / JavaScript ─────────────────────────────
echo -e "\n\033[1;34mJavaScript / TypeScript\033[0m"
install_npm_path "typescript-language-server" "typescript-language-server/bin/typescript-language-server.js"
install_npm "typescript" "tsc"

# ── 6. YAML ────────────────────────────────────────────────
echo -e "\n\033[1;34mYAML\033[0m"
install_npm_path "yaml-language-server" "yaml-language-server/bin/yaml-language-server"

# ── 7. Markdown ────────────────────────────────────────────
echo -e "\n\033[1;34mMarkdown\033[0m"
install_npm "remark-language-server" "remark-language-server"
# remark doesn't create bin symlink, check path instead
NODE_ROOT="$(npm root -g 2>/dev/null)"
if [ -n "$NODE_ROOT" ] && [ -f "$NODE_ROOT/remark-language-server/index.js" ]; then
    echo -e "  \033[0;32m✓\033[0m remark-language-server (path ok)"
fi

# ── 8. PHP ─────────────────────────────────────────────────
echo -e "\n\033[1;34mPHP\033[0m"
install_npm "intelephense"

# ── 9. Python ──────────────────────────────────────────────
echo -e "\n\033[1;34mPython\033[0m"
install_npm "pyright"

# ── 10. Bash ───────────────────────────────────────────────
echo -e "\n\033[1;34mBash\033[0m"
install_npm "bash-language-server"

# ── 11. LSP-MCP (fallback) ─────────────────────────────────
echo -e "\n\033[1;34mLSP-MCP (fallback)\033[0m"
install_npm "lsp-mcp"

# ── Summary ────────────────────────────────────────────────
echo ""
echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "  Resumen: \033[0;32m${INSTALLED} instalados\033[0m, \033[0;31m${FAILED} fallaron\033[0m, \033[0;33m${MISSING} omitidos\033[0m"
echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo -e "\033[1;36m💡 Notas:\033[0m"
echo -e "  • Si algún LSP falló, revisa: npm list -g --depth=0"
echo -e "  • OmniSharp requiere dotnet SDK: https://dotnet.microsoft.com/download"
echo -e "  • Los LSPs se activan automáticamente al abrir archivos correspondientes"
echo ""
