#!/bin/bash
# detect-frameworks.sh — Detecta stack del proyecto y genera analysis.json
# Output: .opencode/analysis.json (formato consumible por opencode)
set -e

PROJECT_DIR="${1:-$(pwd)}"
OPENCODE_DIR="$PROJECT_DIR/.opencode"
ANALYSIS_FILE="$OPENCODE_DIR/analysis.json"

mkdir -p "$OPENCODE_DIR"

HAS_JQ=$(which jq &>/dev/null && echo true || echo false)

# Collect detection results
PROJECT_TYPE=""
FRAMEWORKS="[]"
ARCH=""
PATTERNS="[]"
LANGUAGES="[]"
RECOMMENDATIONS="[]"

# ── Helpers ──
add_to_json_array() {
    local arr="$1"
    local val="$2"
    if [ "$HAS_JQ" = "true" ]; then
        echo "$arr" | jq --arg v "$val" '. + [$v]'
    else
        echo "$arr" | sed "s/]$/\"$val\"]/"
    fi
}

# ── Detect project type ──
# Check for each framework type
detect_dotnet() {
    if find "$PROJECT_DIR" -maxdepth 2 -name "*.csproj" -o -name "*.sln" 2>/dev/null | grep -q .; then
        PROJECT_TYPE=".NET"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["dotnet"]' 2>/dev/null || echo '["dotnet"]')
        
        if find "$PROJECT_DIR" -name "*.cshtml" -o -name "*.razor" 2>/dev/null | grep -q .; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["blazor"]' 2>/dev/null)
            LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["csharp", "razor", "html", "css", "javascript"]' 2>/dev/null)
        fi
        
        if grep -rqi "Radzen\.Blazor" "$PROJECT_DIR" --include="*.csproj" --include="*.cs" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["radzen-blazor"]' 2>/dev/null)
        fi
        if grep -rqi "MudBlazor" "$PROJECT_DIR" --include="*.csproj" --include="*.cs" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["mudblazor"]' 2>/dev/null)
        fi
        if grep -rqi "MediatR" "$PROJECT_DIR" --include="*.csproj" --include="*.cs" 2>/dev/null; then
            PATTERNS=$(echo "$PATTERNS" | jq '. + ["cqrs"]' 2>/dev/null)
        fi
        if grep -rqi "Microsoft.EntityFrameworkCore" "$PROJECT_DIR" --include="*.csproj" --include="*.cs" 2>/dev/null; then
            PATTERNS=$(echo "$PATTERNS" | jq '. + ["repository"]' 2>/dev/null)
        fi
        if grep -rqi "SignalR" "$PROJECT_DIR" --include="*.cs" --include="*.csproj" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["signalr"]' 2>/dev/null)
        fi
        if grep -rqi "Microsoft.AspNetCore.Identity" "$PROJECT_DIR" --include="*.cs" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["identity"]' 2>/dev/null)
        fi
        
        # Architecture detection
        if [ -d "$PROJECT_DIR/Domain" ] && [ -d "$PROJECT_DIR/Application" ]; then
            ARCH="Clean Architecture"
        elif [ -d "$PROJECT_DIR/Controllers" ] && [ -d "$PROJECT_DIR/Views" ]; then
            ARCH="MVC"
        elif find "$PROJECT_DIR" -name "*.csproj" 2>/dev/null | wc -l | grep -q '^[3-9]'; then
            ARCH="Microservices"
        elif [ -f "$PROJECT_DIR/Program.cs" ]; then
            ARCH="API"
        fi
        return 0
    fi
    return 1
}

detect_node() {
    if [ -f "$PROJECT_DIR/package.json" ]; then
        PROJECT_TYPE="Node.js"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["node"]' 2>/dev/null || echo '["node"]')
        
        if grep -qi '"next"' "$PROJECT_DIR/package.json" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["nextjs"]' 2>/dev/null)
        fi
        if grep -qi '"react"' "$PROJECT_DIR/package.json" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["react"]' 2>/dev/null)
        fi
        if grep -qi '"vue"' "$PROJECT_DIR/package.json" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["vue"]' 2>/dev/null)
        fi
        if grep -qi '"@angular/core"' "$PROJECT_DIR/package.json" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["angular"]' 2>/dev/null)
        fi
        
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["javascript", "typescript"]' 2>/dev/null)
        
        if [ -f "$PROJECT_DIR/pnpm-workspace.yaml" ] || [ -f "$PROJECT_DIR/lerna.json" ]; then
            ARCH="Monorepo"
        fi
        return 0
    fi
    return 1
}

detect_python() {
    if [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ] || [ -f "$PROJECT_DIR/setup.py" ]; then
        PROJECT_TYPE="Python"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["python"]' 2>/dev/null || echo '["python"]')
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["python"]' 2>/dev/null)
        
        if grep -qi "django" "$PROJECT_DIR/requirements.txt" 2>/dev/null || [ -f "$PROJECT_DIR/manage.py" ]; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["django"]' 2>/dev/null)
            ARCH="MVC"
        fi
        if grep -qi "flask" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["flask"]' 2>/dev/null)
        fi
        if grep -qi "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["fastapi"]' 2>/dev/null)
        fi
        return 0
    fi
    return 1
}

detect_php() {
    if find "$PROJECT_DIR" -maxdepth 3 -name "*.php" 2>/dev/null | head -1 | grep -q .; then
        PROJECT_TYPE="PHP"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["php"]' 2>/dev/null || echo '["php"]')
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["php"]' 2>/dev/null)
        
        if [ -f "$PROJECT_DIR/artisan" ]; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["laravel"]' 2>/dev/null)
            ARCH="MVC"
        elif [ -f "$PROJECT_DIR/bin/console" ] && [ -d "$PROJECT_DIR/config" ]; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["symfony"]' 2>/dev/null)
        fi
        return 0
    fi
    return 1
}

detect_go() {
    if [ -f "$PROJECT_DIR/go.mod" ]; then
        PROJECT_TYPE="Go"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["go"]' 2>/dev/null || echo '["go"]')
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["go"]' 2>/dev/null)
        
        if grep -qi "gin-gonic" "$PROJECT_DIR/go.mod" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["gin"]' 2>/dev/null)
        fi
        return 0
    fi
    return 1
}

detect_rust() {
    if [ -f "$PROJECT_DIR/Cargo.toml" ]; then
        PROJECT_TYPE="Rust"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["rust"]' 2>/dev/null || echo '["rust"]')
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["rust"]' 2>/dev/null)
        return 0
    fi
    return 1
}

detect_java() {
    if [ -f "$PROJECT_DIR/pom.xml" ] || [ -f "$PROJECT_DIR/build.gradle" ]; then
        PROJECT_TYPE="Java"
        FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["java"]' 2>/dev/null || echo '["java"]')
        LANGUAGES=$(echo "$LANGUAGES" | jq '. + ["java"]' 2>/dev/null)
        
        if grep -qi "spring-boot" "$PROJECT_DIR/pom.xml" "$PROJECT_DIR/build.gradle" 2>/dev/null; then
            FRAMEWORKS=$(echo "$FRAMEWORKS" | jq '. + ["spring-boot"]' 2>/dev/null)
        fi
        return 0
    fi
    return 1
}

# ── Run detection ──
echo ""
echo "  Stack scanning: $PROJECT_DIR"
echo ""

detect_dotnet || detect_node || detect_python || detect_php || detect_go || detect_rust || detect_java || {
    PROJECT_TYPE="Unknown"
}

# ── Build analysis JSON ──
if [ "$HAS_JQ" = "true" ]; then
    jq -n \
      --arg type "${PROJECT_TYPE:-Unknown}" \
      --arg arch "${ARCH:-Layered}" \
      --argjson frameworks "$FRAMEWORKS" \
      --argjson patterns "$PATTERNS" \
      --argjson languages "$LANGUAGES" \
      '{
        project: $type,
        architecture: $arch,
        frameworks: $frameworks,
        patterns: $patterns,
        languages: $languages,
        detected_at: (now | strftime("%Y-%m-%d %H:%M:%S"))
      }' > "$ANALYSIS_FILE"
    
    echo -e "  \033[0;32m✓ analysis.json generado\033[0m"
else
    # Fallback: basic JSON
    cat > "$ANALYSIS_FILE" << EOF
{
  "project": "${PROJECT_TYPE:-Unknown}",
  "architecture": "${ARCH:-Layered}",
  "frameworks": $(echo "$FRAMEWORKS" | sed 's/^\[/[/' 2>/dev/null || echo '[]'),
  "patterns": $(echo "$PATTERNS" | sed 's/^\[/[/' 2>/dev/null || echo '[]'),
  "languages": $(echo "$LANGUAGES" | sed 's/^\[/[/' 2>/dev/null || echo '[]')
}
EOF
    echo -e "  \033[0;33m⚠ analysis.json (fallback sin jq)\033[0m"
fi

# ── Print summary ──
echo ""
echo -e "\033[1;36m  Resumen:\033[0m"
echo -e "  Tipo:       \033[0;32m${PROJECT_TYPE:-Unknown}\033[0m"
echo -e "  Arquitectura: \033[0;32m${ARCH:-Layered}\033[0m"
echo -e "  Frameworks: \033[0;32m$(echo "$FRAMEWORKS" | jq -r '. | join(", ")' 2>/dev/null || echo 'N/A')\033[0m"
echo -e "  Patrones:   \033[0;32m$(echo "$PATTERNS" | jq -r '. | join(", ")' 2>/dev/null || echo 'N/A')\033[0m"
echo ""
echo -e "  Skills sugeridos: npx autoskills"
echo ""
