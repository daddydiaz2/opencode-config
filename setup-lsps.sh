#!/bin/bash
set -e

echo "📦 Instalando Language Servers..."

# NPM global packages
NPM_LSPKS=(
    "pyright"
    "intelephense"
    "bash-language-server"
)

for pkg in "${NPM_LSPKS[@]}"; do
    if npm list -g "$pkg" &>/dev/null; then
        echo "  ✓ $pkg (ya instalado)"
    else
        echo "  📥 Instalando $pkg..."
        npm install -g "$pkg" 2>/dev/null || echo "  ⚠️ $pkg falló (requiere npm)"
    fi
done

echo ""
echo "✅ LSPs instalados:"
echo "  - pyright (Python)"
echo "  - intelephense (PHP)"
echo "  - bash-language-server (Bash)"
echo ""
echo "💡 Para lenguajes adicionales:"
echo "  - Go: go install golang.org/x/tools/gopls@latest"
echo "  - Rust: rustup component add rust-analyzer"
