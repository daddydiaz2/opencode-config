# OpenCode Config

Configuración portable y auto-detectora para OpenCode AI.

## Arquitectura

```
opencode-config/
├── install.sh                 # Detector + generador + instalador
├── uninstall.sh               # Limpieza completa con backup
├── setup-lsps.sh              # 12 Language Servers
├── validate-config.sh         # Validador de configuracion
├── lsp-health-check.sh        # Monitor de salud LSP
├── opencode-config-manager.sh # Backup/restore/update
├── init-project.sh            # Inicializacion por proyecto
├── detect-frameworks.sh       # Deteccion de stack
├── templates/                 # CONFIGURACIONES PORTABLES
│   ├── opencode.json          # Template con placeholder __LSP_*
│   └── agent/core/
│       └── openagent.md       # Template con {{HOME}}
├── VERSION
├── CHANGELOG.md
└── README.md
```

## Principio Clave

**Sin paths hardcodeados.** `install.sh` detecta el sistema y genera configs desde templates con variables.

```
Template (__LSP_CSHARP__) + install.sh (detecta sistema) = Config final portatil
```

## Instalacion

```bash
# Una linea
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash

# Manual
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config
./install.sh
```

## Uso

```bash
# Inicializar proyecto
./init-project.sh /ruta/proyecto

# Validar config generada
./validate-config.sh

# Health check LSPs
./lsp-health-check.sh

# Backup manual
./opencode-config-manager.sh backup

# Restaurar
./opencode-config-manager.sh restore [version]

# Ver status
./opencode-config-manager.sh status
```

## LSPs Soportados

| LSP | Comando | Tipo |
|-----|---------|------|
| C# | omnisharp -lsp | Local |
| Razor/CSHTML | vscode-html-languageserver-bin | Node |
| HTML | vscode-html-languageserver-bin | Node |
| CSS/SCSS | vscode-css-languageserver-bin | Node |
| JavaScript/TypeScript | typescript-language-server | Node |
| JSON | vscode-json-languageserver | Node |
| YAML | yaml-language-server | Node |
| Markdown | remark-language-server | Node |
| PHP | intelephense | Local |
| Python | pyright | Local |
| Bash | bash-language-server | Node |

## MCPs

- **Siempre activos**: context7, git, memory, sequential-thinking, grep, filesystem, microsoft-learn
- **Condicionales** (se agregan si existen en el sistema): radzen-blazor, mudblazor, fluentui, lsp-mcp

## Seguridad

- Filesystem MCP scoped a `.` (workspace actual)
- Backup automatico antes de cualquier cambio
- Rollback via manager

## Requisitos

- bash 4+
- npm (para LSPs Node)
- python3 o jq (para generacion de config)
- dotnet SDK (para OmniSharp C#)
