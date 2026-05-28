# OpenCode Config

Sistema portable de configuración para [OpenCoder AI](https://opencode.ai). Detecta automáticamente el entorno de desarrollo, genera configs dinámicas desde templates (sin paths hardcodeados), instala Language Servers, y provee un ecosistema de scripts para mantener la configuración en el tiempo.

Stack: **bash ≥4** · **Node.js/npm** (LSPs) · **Python3** o **jq** (generación JSON)

---

## Arquitectura

```
opencode-config/
│
├── install.sh                     # ▶ PUNTO DE ENTRADA — detector + generador + instalador
├── uninstall.sh                   # Limpieza completa con backup automático
├── setup-lsps.sh                  # Instalación/actualización de 12 Language Servers
├── validate-config.sh             # Validador post-instalación (JSON, binarios, portabilidad)
├── lsp-health-check.sh            # Monitor de salud de LSPs en ejecución
├── opencode-config-manager.sh     # Gestor: backup, restore, update, status, health
├── init-project.sh                # Inicializa un proyecto existente con estructura opencode
├── detect-frameworks.sh           # Detecta stack tecnológico ( .NET, Node, Python, etc.)
│
├── templates/                     # ◀ CORAZÓN DEL SISTEMA — configs portables con placeholders
│   ├── opencode.json              # Config principal (__LSP_CSHARP__, {{HOME}})
│   ├── agent/core/
│   │   └── openagent.md           # Prompt base del agente ({{HOME}} resuelto dinámicamente)
│   └── context/                   # Documentación de estándares para el agente
│       ├── navigation.md          # Índice de context files
│       └── core/
│           ├── standards/
│           │   ├── code-quality.md
│           │   ├── documentation.md
│           │   └── test-coverage.md
│           └── workflows/
│               ├── code-review.md
│               └── task-delegation-basics.md
│
├── tests/                         # Suite de tests portables (locales + CI)
│   ├── run.sh                     # Test runner
│   ├── test_install.sh            # Instalación en HOME temporal + verificación
│   ├── test_json.sh               # Validación sintaxis JSON
│   ├── test_portability.sh        # 0 paths hardcodeados en templates
│   ├── test_placeholders.sh       # Placeholders {{HOME}} correctos
│   ├── test_shellcheck.sh         # Lint de scripts
│   └── fixtures/
│
├── .github/workflows/ci.yml       # CI: checkout → node → shellcheck → tests/run.sh
├── VERSION
├── CHANGELOG.md
└── README.md
```

### Principio fundamental

**Sin paths hardcodeados.** Los templates usan placeholders (`__LSP_CSHARP__`, `{{HOME}}`). `install.sh` detecta el sistema, resuelve los placeholders, y genera configs funcionales. Misma máquina = misma configuración. Máquina diferente = configuración adaptada.

```
 Template (__LSP_CSHARP__)         install.sh (detecta sistema)          Config final portable
 ┌──────────────────────┐         ┌────────────────────────┐          ┌──────────────────────┐
 │ __LSP_CSHARP__       │  ───→  │ omnisharp encontrado?  │  ───→   │ ["omnisharp", "-lsp"] │
 │ __LSP_RAZOR__        │         │ ¿npm? ¿node?           │          │ ["node", "/usr/lib/..."]│
 │ {{HOME}}/.config/…   │         │ $HOME resuelto         │          │ /home/user/.config/…  │
 └──────────────────────┘         └────────────────────────┘          └──────────────────────┘
```

---

## Componentes Detallados

### Scripts Principales

#### `install.sh` — Instalador principal

**Propósito:** Único comando necesario para poner opencode operativo. Detecta el sistema, genera configs desde templates, instala dependencias, valida el resultado.

**Flujo interno:**
1. **Backup** — si ya existe `~/.config/opencode/`, lo respalda en `~/.config/opencode.backups/pre-install-{timestamp}/`
2. **Detección** — localiza Node.js, Python3, jq, y cada LSP (via `which`, npm global, o rutas conocidas)
3. **Generación** — procesa `templates/opencode.json` con Python (o jq como fallback), resolviendo:
   - `__LSP_*__` → comandos detectados (o `null` si no encontrados)
   - `{{HOME}}` → `$HOME` real
4. **Context files** — copia `templates/context/` resolviendo `{{HOME}}`
5. **Validación** — verifica que el JSON generado sea válido
6. **LSPs** — ejecuta `setup-lsps.sh` para instalar los faltantes
7. **Versión** — escribe `VERSION` y `LAST_INSTALL`

**Flags:**
| Flag | Efecto |
|------|--------|
| `--dry-run` | Solo muestra detección, no escribe nada |
| `--force` | Sobrescribe sin preguntar |
| `--skip-lsps` | Salta instalación de LSPs (útil en CI) |
| `--help` | Muestra ayuda |

```bash
# Instalación normal
./install.sh

# Solo ver detección
./install.sh --dry-run

# Instalación rápida sin LSPs
./install.sh --skip-lsps
```

---

#### `uninstall.sh` — Desinstalador seguro

**Propósito:** Elimina `~/.config/opencode/` con backup automático (`~/.config/opencode.backups/pre-uninstall-{timestamp}/`). No destructivo — siempre hay rollback.

```bash
./uninstall.sh
```

---

#### `setup-lsps.sh` — Instalador de Language Servers

**Propósito:** Instala los 12 Language Servers que opencode necesita. Cada LSP se verifica primero (si ya existe, salta). Usa `npm install -g` y `dotnet tool install` según corresponda.

**LSPs que instala:**

| # | LSP | Tecnología | Instalación |
|---|-----|-----------|-------------|
| 1 | OmniSharp | C# | `dotnet tool install --global Omnisharp` |
| 2 | vscode-html-languageserver-bin | HTML/Razor | `npm install -g` |
| 3 | vscode-css-languageserver-bin | CSS/SCSS | `npm install -g` |
| 4 | vscode-json-languageserver | JSON | `npm install -g` |
| 5 | typescript-language-server | JS/TS | `npm install -g` |
| 6 | typescript | Compilador TS | `npm install -g` |
| 7 | yaml-language-server | YAML | `npm install -g` |
| 8 | remark-language-server | Markdown | `npm install -g` |
| 9 | intelephense | PHP | `npm install -g` |
| 10 | pyright | Python | `npm install -g` |
| 11 | bash-language-server | Bash | `npm install -g` |
| 12 | lsp-mcp | Fallback LSP | `npm install -g` |

```bash
# Instalar todos los LSPs faltantes
./setup-lsps.sh
```

---

#### `validate-config.sh` — Validador de configuración

**Propósito:** Auditoría post-instalación. Verifica 4 aspectos críticos:

1. **JSON válido** — `~/.config/opencode/opencode.json` parsea correctamente
2. **Binarios LSP** — cada comando `command[0]` existe en `$PATH` o en disco
3. **Binarios MCP** — cada MCP local tiene su binario accesible
4. **Portabilidad** — escanea el JSON en busca de paths `/home/...` hardcodeados (deben ser 0)

```bash
# Validar configuración actual
./validate-config.sh
```

**Salida exitosa:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 Validador de Configuración
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Archivo existe
✓ JSON sintaxis válida

Resumen: 11 LSPs | 8 MCPs

LSP Validation:
[OK] bash       -> bash-language-server
[OK] csharp     -> omnisharp
...

✅ Configuración válida y portátil
```

---

#### `opencode-config-manager.sh` — Gestor de configuración

**Propósito:** Operaciones de mantenimiento sobre la instalación activa.

**Subcomandos:**

| Comando | Función |
|---------|---------|
| `backup` | Crea respaldo manual de `~/.config/opencode/` |
| `restore [version]` | Restaura una versión previa (lista disponibles si sin args) |
| `update` | Re-ejecuta `install.sh` sobre la config actual |
| `status` | Muestra versión instalada, fecha, scripts disponibles |
| `health` | Verifica que los archivos críticos existan |

```bash
# Ver estado
./opencode-config-manager.sh status

# Backup manual
./opencode-config-manager.sh backup

# Listar backups disponibles
./opencode-config-manager.sh restore

# Restaurar backup específico
./opencode-config-manager.sh restore pre-install-20260528_065206
```

---

#### `lsp-health-check.sh` — Monitor de salud LSP

**Propósito:** Verifica que los LSPs estén ejecutándose y respondiendo. Útil para debug cuando un LSP no funciona.

```bash
./lsp-health-check.sh
```

---

#### `init-project.sh` — Inicialización por proyecto

**Propósito:** Prepara un proyecto existente para trabajar con opencode. Crea `.opencode/` y `AGENTS.md` con la estructura esperada.

```bash
./init-project.sh /ruta/a/mi-proyecto
```

Genera:
```
proyecto/
├── .opencode/
│   └── tasks/          # Para TaskManager
├── AGENTS.md           # Reglas y contexto del proyecto
```

---

#### `detect-frameworks.sh` — Detección de stack

**Propósito:** Analiza un directorio y detecta el stack tecnológico. Output en JSON compatible con opencode.

```bash
./detect-frameworks.sh /ruta/proyecto
```

Salida:
```json
{
  "frameworks": [".NET", "ASP.NET Core MVC"],
  "languages": ["C#", "JavaScript"],
  "database": "SQL Server",
  "frontend": "Radzen Blazor"
}
```

Este archivo se escribe como `.opencode/analysis.json` en el proyecto destino.

---

### Sistema de Templates

El corazón de la portabilidad. `templates/` contiene configuraciones con placeholders que `install.sh` resuelve dinámicamente.

#### `templates/opencode.json` — Config principal

Template JSON con dos tipos de placeholders:

```json
{
  "lsp": {
    "csharp": __LSP_CSHARP__,
    "razor": __LSP_RAZOR__,
    "html": __LSP_HTML__,
    ...
  },
  "mcp": {
    "filesystem": {
      "command": ["node", "{{HOME}}/.config/opencode/mcp/filesystem.js"]
    }
  }
}
```

**`__LSP_*__`** — Placeholder de JSON array. `install.sh` lo reemplaza por `["omnisharp", "-lsp"]` o `null` si no encontrado.

**`{{HOME}}`** — Placeholder de string. Reemplazado por `$HOME` del usuario actual.

**Procesamiento (Python):**
1. Lee template como texto
2. Reemplaza `__LSP_*__` por arrays JSON reales (vía `resolve_lsp()`)
3. Reemplaza `__*__` restantes por `null`
4. Parsea como JSON y agrega MCPs condicionales
5. Escribe a `~/.config/opencode/opencode.json`

**Fallback (jq):**
Si Python3 no está disponible, usa `sed` para reemplazar placeholders + `jq` para validar. Todos los LSPs quedan como `null`.

---

#### `templates/agent/core/openagent.md` — Prompt del agente

El system prompt que define cómo se comporta opencode. Usa `{{HOME}}` para referenciar context files sin hardcodear rutas.

```markdown
<!-- Antes de ejecutar, cargar contexto desde: -->
{{HOME}}/.config/opencode/context/core/standards/code-quality.md
{{HOME}}/.config/opencode/context/core/workflows/code-review.md
```

---

#### `templates/context/` — Context files (estándares del proyecto)

6 archivos que definen estándares de código, documentación, tests, revisión y delegación. El agente los carga automáticamente antes de ejecutar tareas.

| Archivo | Propósito | Cargado cuando… |
|---------|-----------|-----------------|
| `navigation.md` | Índice de todos los context files | — |
| `standards/code-quality.md` | Convenciones C#, EF, Razor, DataTables, SignaturePad | Se escribe/edita código |
| `standards/documentation.md` | Formato de documentación, commits | Se escribe documentación |
| `standards/test-coverage.md` | Framework de tests, patrones AAA, cobertura | Se escriben tests |
| `workflows/code-review.md` | Checklist de revisión (seguridad, performance, mantenibilidad) | Se revisa código |
| `workflows/task-delegation-basics.md` | Cuándo y cómo delegar a subagentes | Se delegan tareas |

---

### Tests

Suite portable que corre **localmente** y en **CI** con los mismos comandos.

#### `tests/run.sh` — Test runner

```bash
# Todos los tests
bash tests/run.sh

# Modo rápido (salta test_install que necesita HOME temporal)
bash tests/run.sh --quick
```

| Test | Qué verifica | Por qué es importante |
|------|-------------|----------------------|
| `test_install.sh` | Install en HOME temporal → 11 archivos generados, JSON válido, 0 placeholders sin resolver | Garantiza que `install.sh` funciona de extremo a extremo |
| `test_json.sh` | Sintaxis JSON de todos los `.json` (salta templates con placeholders) | Evita commits con JSON roto |
| `test_portability.sh` | 0 paths `/home/` literales en templates/ | Mantiene la portabilidad entre máquinas |
| `test_placeholders.sh` | `{{HOME}}` presente en templates que referencian rutas de usuario | Asegura que no se cuelen paths absolutos |
| `test_shellcheck.sh` | Lint de todos los `.sh` con shellcheck | Previene bugs sutiles en bash |

---

## Instalación

### Una línea (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/daddydiaz2/opencode-config/main/install.sh | bash
```

### Manual

```bash
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config
./install.sh
```

### Docker / CI

```bash
./install.sh --skip-lsps
```

---

## Guía de Uso

### Primera instalación

```bash
git clone https://github.com/daddydiaz2/opencode-config.git
cd opencode-config
./install.sh
```

Esto crea `~/.config/opencode/` con:
- `opencode.json` — 11 LSPs detectados, MCPs activos según sistema
- `agent/core/openagent.md` — prompt portable del agente
- `core/standards/*.md` — estándares de código
- `core/workflows/*.md` — flujos de trabajo
- `VERSION`, `LAST_INSTALL` — metadatos

### Post-instalación

```bash
# Validar que todo está correcto
./validate-config.sh

# Ver estado de la instalación
./opencode-config-manager.sh status
```

### Inicializar un proyecto

```bash
cd /ruta/mi-proyecto
/path/to/opencode-config/init-project.sh .
```

Esto agrega `.opencode/tasks/` y `AGENTS.md` al proyecto.

### Actualizar

```bash
cd opencode-config
git pull
./install.sh
```

El instalador respalda automáticamente la config previa.

### Desinstalar

```bash
cd opencode-config
./uninstall.sh
# Se crea backup automático en ~/.config/opencode.backups/pre-uninstall-*
# Para restaurar: opencode-config-manager.sh restore pre-uninstall-{timestamp}
```

---

## Sistema LSP — Cómo funciona

OpenCode Config maneja 11 Language Servers. Cada uno se resuelve en 2 pasos:

1. **Detección** (`install.sh` → función `resolve_lsp()`):
   - Busca el binario con `which`
   - Si es script Node.js, busca en `npm root -g` + ruta relativa
   - Retorna array JSON `["comando", "argumento"]` o `null`

2. **Instalación** (`setup-lsps.sh`):
   - Verifica si ya está instalado
   - Si no, lo instala vía `npm install -g` o `dotnet tool install`
   - Reporta instalados, fallidos, omitidos

**Caso especial — Razor/HTML/CSS:**
npm instala `vscode-html-languageserver-bin` que crea el symlink `html-languageserver`, no `vscode-html-languageserver`. El script busca por el nombre del symlink real, no el del package.

---

## Sistema MCP — Cuáles y por qué

Los MCPs (Model Context Protocols) son herramientas que opencode expone al agente AI.

### Siempre activos (11)

| MCP | Fuente | Función |
|-----|--------|---------|
| `context7` | opencode built-in | Documentación actualizada de librerías |
| `git` | opencode built-in | Operaciones Git |
| `memory` | opencode built-in | Memoria persistente del agente |
| `sequential-thinking` | opencode built-in | Razonamiento estructurado |
| `grep` | opencode built-in | Búsqueda en código |
| `filesystem` | opencode built-in | Acceso a archivos del workspace |
| `microsoft-learn` | opencode built-in | Documentación Microsoft |
| `radzen-blazor` | Condicional | Documentación Radzen |
| `mudblazor` | Condicional | Documentación MudBlazor |
| `fluentui` | Condicional | Documentación Fluent UI |
| `lsp-mcp` | Condicional | Fallback de LSPs |

### Condicionales

Se agregan automáticamente si los encuentra en el sistema:
- `~/.agents/skills/radzen-mcp/index.js`
- `~/.agents/skills/mudblazor-mcp/index.js`
- `~/.agents/skills/fluentui-mcp/index.js`
- `lsp-mcp` en `$PATH`

---

## Desarrollo

### Correr tests localmente

```bash
# Tests rápidos (sin install)
bash tests/run.sh --quick

# Suite completa (incluye install en HOME temporal)
bash tests/run.sh
```

### Agregar un test

1. Crear `tests/test_mi_feature.sh` con `set -euo pipefail`
2. Exit 0 = pasa, cualquier otro = falla
3. El runner lo descubre automáticamente

### CI/CD

El workflow `.github/workflows/ci.yml` corre en cada push/PR a main:
1. Checkout
2. Setup Node.js
3. Instalar shellcheck
4. `tests/run.sh`

---

## Seguridad

| Aspecto | Medida |
|---------|--------|
| Filesystem MCP | Scoped a `.` (workspace actual, no todo el sistema) |
| Paths hardcodeados | 0 — todos resueltos dinámicamente |
| Backup pre-instalación | Automático, en `~/.config/opencode.backups/` |
| Rollback | `opencode-config-manager.sh restore` |
| Script | `uninstall.sh` respalda antes de eliminar |
| LSPs | Solo npm global + dotnet tool, nada de descargas raw |

---

## Requisitos

| Dependencia | Necesaria para | Notas |
|-------------|---------------|-------|
| bash ≥4 | Todos los scripts | — |
| Node.js ≥18 + npm | LSPs Node, `templates/opencode.json` | 10 de 12 LSPs son Node |
| Python3 ≥3.8 | Procesamiento de templates | Fallback a jq si no existe |
| jq | Fallback de templates | Solo si no hay Python3 |
| .NET SDK | OmniSharp (LSP C#) | Opcional, los demás LSPs funcionan igual |
