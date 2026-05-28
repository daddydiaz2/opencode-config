#!/bin/bash
set -e

echo "🔍 Detectando frameworks del proyecto..."
echo ""

PROJECT_DIR="${1:-$(pwd)}"
MCP_FILE="$PROJECT_DIR/.opencode/mcp.json"

# Inicializar archivo MCP
mkdir -p "$PROJECT_DIR/.opencode"
echo '{
  "$schema": "https://opencode.ai/mcp-schema.json",
  "mcp": {
    "description": "MCPs específicos del proyecto (auto-generados por detect-frameworks.sh)",
    "servers": []
  }
}' > "$MCP_FILE"

# Contadores
DETECTED=0

# === .NET Projects ===
if find "$PROJECT_DIR" -name "*.csproj" -o -name "*.sln" 2>/dev/null | grep -q .; then
    echo "📦 Proyecto .NET detectado"

    # Radzen.Blazor
    if grep -rqi "Radzen\.Blazor\|RadzenBlazor" "$PROJECT_DIR" 2>/dev/null; then
        echo "  ✓ Radzen.Blazor → radzen-blazor MCP"
        jq '.mcp.servers += ["radzen-blazor"]' "$MCP_FILE" > /tmp/mcp.json && mv /tmp/mcp.json "$MCP_FILE"
        ((DETECTED++))
    fi

    # MudBlazor
    if grep -rqi "MudBlazor" "$PROJECT_DIR" 2>/dev/null; then
        echo "  ✓ MudBlazor → mudblazor MCP"
        jq '.mcp.servers += ["mudblazor"]' "$MCP_FILE" > /tmp/mcp.json && mv /tmp/mcp.json "$MCP_FILE"
        ((DETECTED++))
    fi

    # FluentValidation
    if grep -rqi "FluentValidation" "$PROJECT_DIR" 2>/dev/null; then
        echo "  ✓ FluentValidation → fluentui MCP"
        jq '.mcp.servers += ["fluentui"]' "$MCP_FILE" > /tmp/mcp.json && mv /tmp/mcp.json "$MCP_FILE"
        ((DETECTED++))
    fi

    # Blazor
    if find "$PROJECT_DIR" -name "*.razor" 2>/dev/null | grep -q .; then
        echo "  ✓ Blazor detectado"
    fi
fi

# === Node.js Projects ===
if [ -f "$PROJECT_DIR/package.json" ]; then
    echo "📦 Proyecto Node.js detectado"

    # React
    if grep -qi '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        echo "  ✓ React → react skills"
        ((DETECTED++))
    fi

    # Vue
    if grep -qi '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        echo "  ✓ Vue → vue skills"
        ((DETECTED++))
    fi

    # Next.js
    if grep -qi '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        echo "  ✓ Next.js → next skills"
        ((DETECTED++))
    fi

    # Angular
    if grep -qi '"@angular/core"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        echo "  ✓ Angular → angular skills"
        ((DETECTED++))
    fi
fi

# === Python Projects ===
if [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ]; then
    echo "📦 Proyecto Python detectado"
    echo "  ✓ pyright LSP disponible"
    ((DETECTED++))
fi

# === Go Projects ===
if [ -f "$PROJECT_DIR/go.mod" ]; then
    echo "📦 Proyecto Go detectado"
    echo "  ✓ gopls LSP disponible (requiere instalación manual: go install golang.org/x/tools/gopls@latest)"
    ((DETECTED++))
fi

# === Rust Projects ===
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    echo "📦 Proyecto Rust detectado"
    echo "  ✓ rust-analyzer disponible (requiere: rustup component add rust-analyzer)"
    ((DETECTED++))
fi

# === PHP Projects ===
if find "$PROJECT_DIR" -name "*.php" 2>/dev/null | head -1 | grep -q .; then
    echo "📦 Proyecto PHP detectado"
    echo "  ✓ intelephense LSP disponible"
    ((DETECTED++))
fi

echo ""
echo "✅ Detección completa: $DETECTED frameworks detectados"
echo ""
echo "📄 MCP config guardado en: $MCP_FILE"
echo ""
echo "📋 Frameworks detectados:"
cat "$MCP_FILE" | jq -r '.mcp.servers[]' 2>/dev/null || echo "  (ninguno - usa MCPs universales)"

echo ""
echo "🚀 Próximos pasos:"
echo "  1. cd $PROJECT_DIR"
echo "  2. npx autoskills (para instalar skills del proyecto)"
echo "  3. opencode (para empezar a trabajar)"
