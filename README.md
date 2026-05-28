# 🚀 OpenCode Config

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue?style=for-the-badge)
![OpenCode](https://img.shields.io/badge/OpenCode-1.15.11-2563eb?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Scoped-success?style=for-the-badge)

**Configuración Enterprise Multi-Proyecto para OpenCode AI**

*Seguridad, monitoreo, auto-detección inteligente y rollback automático*

[Instalación](#-instalación-rápida) • [Features](#-features) • [Seguridad](#-seguridad) • [Health](#-health-monitoring) • [FAQ](#-faq)

</div>

---

## 📋 Tabla de Contenidos

- [🚀 OpenCode Config](#-opencode-config)
  - [📋 Tabla de Contenidos](#-tabla-de-contenidos)
  - [✨ Features](#-features)
  - [🛡️ Seguridad](#️-seguridad)
  - [🏥 Health Monitoring](#-health-monitoring)
  - [🧠 Inteligencia de Proyecto](#-inteligencia-de-proyecto)
  - [⚡ Instalación Rápida](#-instalación-rápida)
  - [📖 Uso](#-uso)
  - [🔧 Configuración](#-configuración)
  - [🔄 Actualización y Rollback](#-actualización-y-rollback)
  - [🐛 Troubleshooting](#-troubleshooting)
  - [🤝 Contribuir](#-contribuir)
  - [📄 Licencia](#-licencia)

---

## ✨ Features

### 🔒 Seguridad Enterprise
- **Filesystem Scoped**: MCP filesystem limitado al workspace actual (no acceso global)
- **Backup Automático**: Backup antes de cualquier cambio
- **Rollback Instantáneo**: Vuelve a versión anterior si algo falla

### 🏥 Health Monitoring
- **LSP Health Checks**: Verificación automática de Language Servers
- **Circuit Breaker**: Timeout inteligente (45s → retry → fallback)
- **Self-Healing**: Reinicio automático de LSPs caídos

### 🧠 Inteligencia de Proyecto
- **Auto-detección de Frameworks**: Radzen, MudBlazor, React, Vue, Angular, Django, etc.
- **Detección de Arquitectura**: Clean Architecture, MVC, Microservicios, Monorepo
- **Detección de Patrones**: CQRS, MediatR, Repository, Unit of Work
- **Sugerencias Inteligentes**: Recomienda skills basado en stack detectado

### 🛠️ LSPs Configurados

| Lenguaje | LSP | Estado | Fallback |
|----------|-----|--------|----------|
| C# | OmniSharp | ✅ | lsp-mcp |
| Razor / Blazor | vscode-html-ls | ✅ | - |
| Python | pyright | ✅ | - |
| PHP | intelephense | ✅ | - |
| JavaScript / TypeScript | typescript-language-server | ✅ | - |
| HTML / CSS / JSON | vscode-{html,css,json}-ls | ✅ | - |
| YAML | yaml-language-server | ✅ | - |
| Markdown | remark-language-server | ✅ | - |
| Bash | bash-language-server | ✅ | - |
| Go | gopls | ⚠️ Requiere instalar | - |
| Rust | rust-analyzer | ⚠️ Requiere instalar | - |

---

## 🛡️ Seguridad

### Scope de Filesystem MCP

**Antes (Inseguro):**
```json
"filesystem": {
  "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/home/daniel"]
}
```
❌ Acceso a TODO el home del usuario

**Ahora (Seguro):**
```json
"filesystem": {
  "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."]
}
```
✅ Solo acceso al workspace actual

### Backup Automático

Cada cambio crea backup automático:
```bash
~/.config/opencode.backups/
├── pre-update-20240528_143022/
├── pre-update-20240528_152145/
└── manual-20240528_160000/
```

---

## 🏥 Health Monitoring

### Comandos de Health Check

```bash
# Verificar salud de todos los LSPs
./lsp-health-check.sh

# Verificar salud general
./opencode-config-manager.sh health

# Status completo
./opencode-config-manager.sh status
```

### Circuit Breaker Pattern

```
LSP falla → Retry 1 (5s) → Retry 2 (10s) → Fallback → Notify user
```

### Monitoreo Automático

- **Timeout**: 45 segundos máximo por LSP
- **Retry**: 2 intentos antes de fallback
- **Fallback**: OmniSharp → lsp-mcp → syntax básico
- **Logging**: Todos los errores en `~/.config/opencode/logs/`

---

## 🧠 Inteligencia de Proyecto

### Detección de Arquitectura

```bash
./detect-frameworks.sh /tu-proyecto
```

**Detecta automáticamente:**

| Patrón | Indicadores |
|--------|-------------|
| **Clean Architecture** | `Domain/`, `Application/`, `Infrastructure/` |
| **MVC** | `Controllers/`, `Models/`, `Views/` |
| **Microservices** | Múltiples `.csproj` + `Services/` |
| **API / Minimal API** | `Program.cs` sin `Views/` |
| **Monorepo** | `pnpm-workspace.yaml`, `lerna.json` |

### Frameworks Soportados

** .NET:**
- Radzen.Blazor → radzen-blazor MCP
- MudBlazor → mudblazor MCP
- FluentValidation → fluentui MCP
- MediatR → CQRS patterns
- SignalR → Tiempo real
- gRPC → APIs de alto rendimiento

**Node.js:**
- React, Vue, Angular, Next.js
- TypeScript (auto-detectado)

**Python:**
- Django, Flask, FastAPI

**Otros:**
- Go (Gin, Echo)
- Rust (Actix)
- PHP (Laravel, Symfony)
- Java (Spring Boot)

---

## ⚡ Instalación Rápida

### Una línea (global)

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

### Instalación Manual

```bash
# 1. Clonar repo
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config

# 2. Instalar
chmod +x install.sh
./install.sh

# 3. Verificar instalación
./opencode-config-manager.sh health
```

---

## 📖 Uso

### Inicializar Nuevo Proyecto

```bash
cd /tu-proyecto
./init-project.sh
```

**Esto hace:**
1. 🔍 Detecta frameworks y arquitectura
2. 📦 Ejecuta `npx autoskills`
3. 📝 Genera `.opencode/mcp.json` con MCPs específicos
4. 📊 Genera `.opencode/analysis.json` con análisis completo

### Manager de Config

```bash
# Crear backup manual
./opencode-config-manager.sh backup

# Listar backups disponibles
./opencode-config-manager.sh list

# Restaurar último backup
./opencode-config-manager.sh restore

# Restaurar versión específica
./opencode-config-manager.sh restore pre-update-20240528_143022

# Actualizar a última versión
./opencode-config-manager.sh update

# Ver status
./opencode-config-manager.sh status
```

---

## 🔧 Configuración

### Estructura del Proyecto

```
opencode-config/
├── install.sh                          # Instalación global
├── opencode-config-manager.sh          # Manager (backup/restore/update)
├── lsp-health-check.sh                 # Health checks de LSPs
├── detect-frameworks.sh                # Detección inteligente
├── init-project.sh                     # Inicializar proyecto
├── setup-lsps.sh                       # Instalar Language Servers
├── configs/
│   ├── global/
│   │   ├── opencode.json               # Config principal (LSPs + MCPs)
│   │   └── agent/core/openagent.md     # Prompt sistema (español + profesional)
│   └── project-template/
│       └── .opencode/
│           ├── mcp.json                # Template MCPs proyecto
│           └── analysis.json           # Template análisis
└── .github/workflows/
    └── test.yml                        # CI/CD tests
```

### Configuración del Sistema

**Archivo:** `~/.config/opencode/opencode.json`

```json
{
  "lsp": {
    "csharp": {
      "command": ["omnisharp", "-lsp"],
      "extensions": [".cs"],
      "timeout": 30000
    }
  },
  "mcp": {
    "filesystem": {
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."],
      "description": "Scoped to current workspace only"
    }
  }
}
```

### Variables de Entorno

```bash
# Opcional: API key para Context7
export CONTEXT7_API_KEY="tu-api-key"

# Opcional: Timeout personalizado para LSPs
export LSP_TIMEOUT=45000
```

---

## 🔄 Actualización y Rollback

### Actualización Segura

```bash
# Método 1: Manager automático
./opencode-config-manager.sh update

# Método 2: Manual con backup
cp -r ~/.config/opencode ~/.config/opencode.backup.$(date +%s)
cd /tmp/opencode-config && git pull && ./install.sh
```

### Rollback

```bash
# Si algo falló después de actualizar
./opencode-config-manager.sh restore

# O restaurar versión específica
./opencode-config-manager.sh restore pre-update-20240528_143022
```

---

## 🐛 Troubleshooting

### LSP no responde

```bash
# Verificar health
./lsp-health-check.sh

# Reiniciar opencode
exit
opencode /tu-proyecto

# Ver logs detallados
cat ~/.local/share/opencode/log/*.log | grep ERROR
```

### Timeout en LSP

```bash
# Verificar que OmniSharp funciona
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":1234,"rootUri":"file:///tu-proyecto","capabilities":{},"clientInfo":{"name":"test","version":"1.0"},"protocolVersion":"2024-11-05"}}' | timeout 10 omnisharp -lsp

# Si falla, reinstalar
./setup-lsps.sh
```

### MCP no carga

```bash
# Verificar status
opencode mcp list

# Debuggear específico
opencode mcp debug <nombre-mcp>

# Verificar filesystem scoped
# Debe mostrar "." (workspace actual), no "/home/usuario"
```

### Restaurar configuración limpia

```bash
# Backup primero
./opencode-config-manager.sh backup

# Restaurar factory defaults
rm -rf ~/.config/opencode
./install.sh
```

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea feature branch (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -m 'feat: Agregar nueva funcionalidad'`)
4. Push a branch (`git push origin feature/nueva-funcionalidad`)
5. Abre Pull Request

### Guías de Contribución

- Seguir [Conventional Commits](https://www.conventionalcommits.org/)
- Incluir tests para nuevos features
- Documentar cambios en README
- Mantener compatibilidad hacia atrás

---

## 📄 Licencia

MIT © daddydiaz2

---

<div align="center">

**Hecho con ❤️ para desarrolladores profesionales**

[⬆ Volver arriba](#-opencode-config)

</div>
