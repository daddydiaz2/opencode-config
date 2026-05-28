#!/bin/bash
set -e

echo "🔍 Detectando frameworks y patrones del proyecto..."
echo ""

PROJECT_DIR="${1:-$(pwd)}"
MCP_FILE="$PROJECT_DIR/.opencode/mcp.json"
ANALYSIS_FILE="$PROJECT_DIR/.opencode/analysis.json"

# Inicializar archivos
mkdir -p "$PROJECT_DIR/.opencode"

# Template MCP
cat > "$MCP_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/mcp-schema.json",
  "mcp": {
    "description": "MCPs específicos del proyecto (auto-generados)",
    "servers": [],
    "autoDetected": true
  }
}
EOF

# Template Analysis
cat > "$ANALYSIS_FILE" << 'EOF'
{
  "projectType": null,
  "frameworks": [],
  "architecture": null,
  "patterns": [],
  "lsps": [],
  "recommendations": []
}
EOF

# Contadores
DETECTED=0
FRAMEWORKS=()
ARCHITECTURE=""
PATTERNS=()

# Función para agregar MCP
add_mcp() {
    local mcp_name="$1"
    local reason="$2"
    
    if ! grep -q "$mcp_name" "$MCP_FILE"; then
        jq --arg mcp "$mcp_name" --arg reason "$reason" \
           '.mcp.servers += [{"name": $mcp, "reason": $reason}]' \
           "$MCP_FILE" > /tmp/mcp.json && mv /tmp/mcp.json "$MCP_FILE"
        ((DETECTED++))
        FRAMEWORKS+=("$mcp_name")
        echo "  ✓ $mcp_name → $reason"
    fi
}

# Función para detectar arquitectura
detect_architecture() {
    local dir="$1"
    
    # Clean Architecture / Onion / Hexagonal
    if [ -d "$dir/Domain" ] && [ -d "$dir/Application" ] && [ -d "$dir/Infrastructure" ]; then
        ARCHITECTURE="Clean Architecture"
        PATTERNS+=("CQRS" "Mediator" "Repository")
        echo "  🏗️  Arquitectura: Clean Architecture (Domain, Application, Infrastructure)"
    
    # MVC tradicional
    elif [ -d "$dir/Controllers" ] && [ -d "$dir/Models" ] && [ -d "$dir/Views" ]; then
        ARCHITECTURE="MVC"
        PATTERNS+=("Repository" "Unit of Work")
        echo "  🏗️  Arquitectura: MVC (Controllers, Models, Views)"
    
    # Microservicios
    elif [ -d "$dir/Services" ] && [ $(find "$dir" -name "*.csproj" | wc -l) -gt 3 ]; then
        ARCHITECTURE="Microservices"
        PATTERNS+=("API Gateway" "Service Discovery")
        echo "  🏗️  Arquitectura: Microservices ($(find "$dir" -name "*.csproj" | wc -l) proyectos)"
    
    # API / Minimal API
    elif [ -f "$dir/Program.cs" ] && ! [ -d "$dir/Views" ]; then
        ARCHITECTURE="API"
        PATTERNS+=("REST" "Dependency Injection")
        echo "  🏗️  Arquitectura: API / Backend"
    fi
}

# === .NET Projects ===
if find "$PROJECT_DIR" -name "*.csproj" -o -name "*.sln" 2>/dev/null | grep -q .; then
    echo "📦 Proyecto .NET detectado"
    
    # Detectar arquitectura
    detect_architecture "$PROJECT_DIR"
    
    # Blazor / Razor
    if find "$PROJECT_DIR" -name "*.razor" -o -name "*.cshtml" 2>/dev/null | grep -q .; then
        echo "  🎨 Frontend: Blazor/Razor detectado"
    fi
    
    # Radzen.Blazor
    if grep -rqi "Radzen\.Blazor\|RadzenBlazor" "$PROJECT_DIR" 2>/dev/null; then
        add_mcp "radzen-blazor" "Componentes UI Radzen"
    fi

    # MudBlazor
    if grep -rqi "MudBlazor" "$PROJECT_DIR" 2>/dev/null; then
        add_mcp "mudblazor" "Componentes UI MudBlazor"
    fi

    # FluentValidation
    if grep -rqi "FluentValidation" "$PROJECT_DIR" 2>/dev/null; then
        add_mcp "fluentui" "Validación FluentValidation"
    fi
    
    # MediatR (CQRS)
    if grep -rqi "MediatR" "$PROJECT_DIR" 2>/dev/null; then
        PATTERNS+=("CQRS" "Mediator Pattern")
        echo "  🧩 Patrón: MediatR detectado"
    fi
    
    # Entity Framework
    if grep -rqi "Microsoft.EntityFrameworkCore" "$PROJECT_DIR" 2>/dev/null; then
        PATTERNS+=("Repository Pattern" "Unit of Work")
        echo "  🧩 Patrón: Entity Framework detectado"
    fi
    
    # SignalR
    if grep -rqi "Microsoft.AspNetCore.SignalR" "$PROJECT_DIR" 2>/dev/null; then
        add_mcp "signalr" "Tiempo real con SignalR"
    fi
    
    # Identity
    if grep -rqi "Microsoft.AspNetCore.Identity" "$PROJECT_DIR" 2>/dev/null; then
        echo "  🔐 Auth: ASP.NET Identity detectado"
    fi
    
    # gRPC
    if grep -rqi "Grpc" "$PROJECT_DIR" 2>/dev/null; then
        echo "  📡 API: gRPC detectado"
    fi
fi

# === Node.js Projects ===
if [ -f "$PROJECT_DIR/package.json" ]; then
    echo "📦 Proyecto Node.js detectado"
    
    # Detectar framework
    if grep -qi '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        add_mcp "react" "Framework React"
    fi

    if grep -qi '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        add_mcp "vue" "Framework Vue"
    fi

    if grep -qi '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        add_mcp "next" "Framework Next.js"
    fi

    if grep -qi '"@angular/core"' "$PROJECT_DIR/package.json" 2>/dev/null; then
        add_mcp "angular" "Framework Angular"
    fi
    
    # TypeScript
    if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
        echo "  📘 TypeScript configurado"
    fi
    
    # Monorepo
    if [ -f "$PROJECT_DIR/pnpm-workspace.yaml" ] || [ -f "$PROJECT_DIR/lerna.json" ]; then
        ARCHITECTURE="Monorepo"
        echo "  📦 Arquitectura: Monorepo detectado"
    fi
fi

# === Python Projects ===
if [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ]; then
    echo "📦 Proyecto Python detectado"
    
    # Django
    if grep -qi "django" "$PROJECT_DIR/requirements.txt" 2>/dev/null || [ -f "$PROJECT_DIR/manage.py" ]; then
        add_mcp "django" "Framework Django"
        ARCHITECTURE="MVC" 
    fi
    
    # Flask
    if grep -qi "flask" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
        add_mcp "flask" "Framework Flask"
    fi
    
    # FastAPI
    if grep -qi "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
        add_mcp "fastapi" "Framework FastAPI"
    fi
    
    echo "  🐍 LSP: pyright disponible"
fi

# === Go Projects ===
if [ -f "$PROJECT_DIR/go.mod" ]; then
    echo "📦 Proyecto Go detectado"
    
    # Gin
    if grep -qi "gin-gonic" "$PROJECT_DIR/go.mod" 2>/dev/null; then
        add_mcp "gin" "Framework Gin"
    fi
    
    # Echo
    if grep -qi "labstack/echo" "$PROJECT_DIR/go.mod" 2>/dev/null; then
        add_mcp "echo" "Framework Echo"
    fi
    
    echo "  🐹 LSP: gopls disponible (requiere: go install golang.org/x/tools/gopls@latest)"
fi

# === Rust Projects ===
if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
    echo "📦 Proyecto Rust detectado"
    
    # Actix
    if grep -qi "actix" "$PROJECT_DIR/Cargo.toml" 2>/dev/null; then
        add_mcp "actix" "Framework Actix"
    fi
    
    echo "  ⚙️  LSP: rust-analyzer disponible (requiere: rustup component add rust-analyzer)"
fi

# === PHP Projects ===
if find "$PROJECT_DIR" -name "*.php" 2>/dev/null | head -1 | grep -q .; then
    echo "📦 Proyecto PHP detectado"
    
    # Laravel
    if [ -f "$PROJECT_DIR/artisan" ]; then
        add_mcp "laravel" "Framework Laravel"
        ARCHITECTURE="MVC"
    fi
    
    # Symfony
    if [ -f "$PROJECT_DIR/bin/console" ] && [ -d "$PROJECT_DIR/config" ]; then
        add_mcp "symfony" "Framework Symfony"
    fi
    
    echo "  🐘 LSP: intelephense disponible"
fi

# === Java Projects ===
if [ -f "$PROJECT_DIR/pom.xml" ] || [ -f "$PROJECT_DIR/build.gradle" ]; then
    echo "📦 Proyecto Java detectado"
    
    # Spring Boot
    if grep -qi "spring-boot" "$PROJECT_DIR/pom.xml" "$PROJECT_DIR/build.gradle" 2>/dev/null; then
        add_mcp "spring-boot" "Framework Spring Boot"
        ARCHITECTURE="MVC / Layered"
    fi
    
    echo "  ☕ LSP: jdtls disponible (requiere instalación)"
fi

# Guardar análisis
jq --arg arch "${ARCHITECTURE:-Unknown}" \
   --argjson frameworks "$(printf '%s\n' "${FRAMEWORKS[@]}" | jq -R . | jq -s .)" \
   --argjson patterns "$(printf '%s\n' "${PATTERNS[@]}" | jq -R . | jq -s .)" \
   '.projectType = "'$(basename "$PROJECT_DIR")'" |
    .architecture = $arch |
    .frameworks = $frameworks |
    .patterns = $patterns |
    .lsps = ["csharp", "razor", "html", "css", "javascript", "json", "yaml", "markdown"]' \
   "$ANALYSIS_FILE" > /tmp/analysis.json && mv /tmp/analysis.json "$ANALYSIS_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Análisis completo: $DETECTED frameworks/patrones detectados"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Mostrar resumen
if [ -f "$ANALYSIS_FILE" ]; then
    echo "📊 Resumen del proyecto:"
    cat "$ANALYSIS_FILE" | jq -r '
        "  Tipo: \(.projectType)",
        "  Arquitectura: \(.architecture)",
        "  Frameworks: \(.frameworks | join(", "))",
        "  Patrones: \(.patterns | join(", "))"
    '
fi

echo ""
echo "📄 Configuraciones generadas:"
echo "  • MCPs: $MCP_FILE"
echo "  • Análisis: $ANALYSIS_FILE"
echo ""

# Sugerencias inteligentes
echo "💡 Recomendaciones:"
if [ ${#PATTERNS[@]} -gt 0 ]; then
    echo "  • Skills sugeridos para patrones detectados:"
    for pattern in "${PATTERNS[@]}"; do
        echo "    - $pattern best practices"
    done
fi

if [ "$DETECTED" -eq 0 ]; then
    echo "  • No se detectaron frameworks específicos"
    echo "  • Ejecuta 'npx autoskills' para análisis más profundo"
fi

echo ""
echo "🚀 Próximos pasos:"
echo "  1. npx autoskills (instalar skills del proyecto)"
echo "  2. opencode (empezar a trabajar)"
echo ""
