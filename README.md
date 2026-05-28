# OpenCode Config — Configuración Profesional Multi-Proyecto

## Instalación Global (una vez)

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

## Características

- **LSPs**: csharp, razor, html, css, javascript, typescript, json, yaml, markdown, php, python, bash
- **MCPs Universales**: context7, git, memory, filesystem
- **Auto-detección de Frameworks**: Radzen, MudBlazor, FluentUI, React, Vue, Angular
- **Skills Automáticos**: `npx autoskills` detecta el stack del proyecto
- **Modo Profesional**: Siempre análisis + opciones + comentarios en español
- **Caveman Mode**: Ultra-comprimido por defecto (~75% tokens)

## Estructura

- `install.sh` — Instalación global
- `setup-lsps.sh` — Instala Language Servers
- `detect-frameworks.sh` — Detecta frameworks y carga MCPs
- `init-project.sh` — Inicializa nuevo proyecto con .opencode/ y autoskills

## Para Nuevo Proyecto

```bash
cd /tu-proyecto
./init-project.sh
```

Esto:
1. Detecta el stack (Python, .NET, Node, etc.)
2. Ejecuta `npx autoskills`
3. Genera `.opencode/` con MCPs específicos
4. Lista skills detectados

## Detección Automática de Frameworks

| Framework | MCP Detectado |
|-----------|---------------|
| Radzen.Blazor | radzen-blazor |
| MudBlazor | mudblazor |
| FluentValidation | fluentui |
| React | react skills |
| Vue | vue skills |
| Python | pyright |

## Actualizar

```bash
cd ~/.config/opencode
git pull origin main
```

## Requisitos

- Node.js 18+ (para npx autoskills y LSPs npm)
- Git
- curl

## Soporte de Lenguajes

| Lenguaje | LSP | Notas |
|----------|-----|-------|
| C# | lsp-mcp | Requiere lsp-mcp instalado |
| ASP.NET Core | lsp-mcp | Via lsp-mcp |
| Python | pyright | npm install -g pyright |
| PHP | intelephense | npm install -g intelephense |
| JavaScript/TypeScript | typescript-language-server | Incluido |
| HTML | vscode-html-languageserver | Incluido |
| CSS | vscode-css-languageserver | Incluido |
| JSON | vscode-json-languageserver | Incluido |
| YAML | yaml-language-server | Incluido |
| Markdown | remark-language-server | Incluido |
| Bash | bash-language-server | npm install -g bash-language-server |
| Go | gopls | go install golang.org/x/tools/gopls@latest |
| Rust | rust-analyzer | rustup component add rust-analyzer |

## Licencia

MIT
